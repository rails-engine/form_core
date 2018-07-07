# frozen_string_literal: true

module Concerns::Fields
  module Validations::Numericality
    extend ActiveSupport::Concern

    included do
      embeds_one :numericality, class_name: "Concerns::Fields::Validations::Numericality::NumericalityOptions"
      accepts_nested_attributes_for :numericality

      after_initialize do
        build_numericality unless numericality
      end
    end

    def interpret_to(model, field_name, accessibility, options = {})
      super
      numericality&.interpret_to model, field_name, accessibility, options
    end

    class NumericalityOptions < FieldOptions
      attribute :lower_bound_check, :string, default: "disabled"
      attribute :upper_bound_check, :string, default: "disabled"

      attribute :lower_bound_value, :float, default: 0.0
      attribute :upper_bound_value, :float, default: 0.0

      enum lower_bound_check: {
        disabled: "disabled",
        greater_than: "greater_than",
        greater_than_or_equal_to: "greater_than_or_equal_to"
      }, _prefix: :lower_bound_check
      enum upper_bound_check: {
        disabled: "disabled",
        less_than: "less_than",
        less_than_or_equal_to: "less_than_or_equal_to"
      }, _prefix: :upper_bound_check

      validates :upper_bound_value,
                numericality: {
                  greater_than: :lower_bound_value
                },
                if: proc { upper_bound_check != "disabled" && lower_bound_check != "disabled" }

      def interpret_to(model, field_name, _accessibility, _options = {})
        options = {}
        options[lower_bound_check] = lower_bound_value unless lower_bound_check_disabled?
        options[upper_bound_check] = upper_bound_value unless upper_bound_check_disabled?
        return if options.empty?

        options.symbolize_keys!
        model.validates field_name, numericality: options, allow_blank: true
      end
    end
  end
end
