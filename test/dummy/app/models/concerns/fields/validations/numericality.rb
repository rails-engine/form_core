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
      attribute :lower_value, :float, default: 0.0
      attribute :upper_value, :float, default: 0.0

      enum lower_bound: {
        disabled: "disabled",
        greater_than: "greater_than",
        greater_than_or_equal_to: "greater_than_or_equal_to"
      }, _prefix: :lower_bound
      enum upper_bound: {
        disabled: "disabled",
        less_than: "less_than",
        less_than_or_equal_to: "less_than_or_equal_to"
      }, _prefix: :upper_bound

      attribute :lower_bound, :string, default: "disabled"
      attribute :upper_bound, :string, default: "disabled"

      def greater_than=(value)
        self.lower_bound = "greater_than"
        self.lower_value = value
      end

      def greater_than_or_equal_to=(value)
        self.lower_bound = "greater_than_or_equal_to"
        self.lower_value = value
      end

      def less_than=(value)
        self.upper_bound = "less_than"
        self.upper_value = value
      end

      def less_than_or_equal_to=(value)
        self.upper_bound = "less_than_or_equal_to"
        self.upper_value = value
      end

      validates :upper_value,
                numericality: {
                  greater_than: :lower_value
                },
                if: proc { upper_bound != "disabled" && lower_bound != "disabled" }

      def interpret_to(model, field_name, _accessibility, _options = {})
        options = {}
        options[lower_bound] = lower_value unless lower_bound_disabled?
        options[upper_bound] = upper_value unless upper_bound_disabled?
        return if options.empty?

        model.validates field_name, numericality: options, allow_blank: true
      end
    end
  end
end
