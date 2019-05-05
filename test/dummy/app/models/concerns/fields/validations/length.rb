# frozen_string_literal: true

module Fields
  module Validations::Length
    extend ActiveSupport::Concern

    included do
      embeds_one :length, class_name: "Fields::Validations::Length::LengthOptions"
      accepts_nested_attributes_for :length

      after_initialize do
        build_length unless length
      end
    end

    def interpret_to(model, field_name, accessibility, options = {})
      super
      length&.interpret_to model, field_name, accessibility, options
    end

    class LengthOptions < FieldOptions
      attribute :minimum, :integer, default: 0
      attribute :maximum, :integer, default: 0
      attribute :is, :integer, default: 0

      validates :minimum, :maximum, :is,
                numericality: {
                  greater_than_or_equal_to: 0
                }
      validates :maximum,
                numericality: {
                  greater_than: :minimum
                },
                if: proc { |record| record.maximum <= record.minimum && record.maximum.positive? }

      validates :is,
                numericality: {
                  equal_to: 0
                },
                if: proc { |record| !record.maximum.zero? || !record.minimum.zero? }

      def interpret_to(model, field_name, _accessibility, _options = {})
        return if minimum.zero? && maximum.zero? && is.zero?

        if is.positive?
          model.validates field_name, length: { is: is }, allow_blank: true
          return
        end

        options = {}
        options[:minimum] = minimum if minimum.positive?
        options[:maximum] = maximum if maximum.positive?
        return if options.empty?

        model.validates field_name, length: options, allow_blank: true
      end
    end
  end
end
