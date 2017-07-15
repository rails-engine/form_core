module Concerns::Fields
  module Validations::Numericality
    extend ActiveSupport::Concern

    included do
      embeds_one :numericality, anonymous_class: NumericalityOptions
    end

    def interpret_to(model, field_name, accessibility, options = {})
      super
      numericality.interpret_to model, field_name, accessibility, options
    end

    class NumericalityOptions < FieldOptions
      attribute_names.merge [:lower_bound, :upper_bound]

      attribute :lower_value, :float, default: 0.0
      attribute :upper_value, :float, default: 0.0

      enum_attribute :lower_bound, %w(disabled greater_than greater_than_or_equal_to), default: "disabled"
      enum_attribute :upper_bound, %w(disabled less_than less_than_or_equal_to), default: "disabled"

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
        options[lower_bound] = lower_value unless lower_bound == "disabled"
        options[upper_bound] = upper_value unless upper_bound == "disabled"
        return if options.empty?

        model.validates field_name, numericality: options, allow_blank: true
      end

      def to_h
        hash = {}

        if upper_bound != "disabled"
          hash[upper_bound] = upper_value
        end

        if lower_bound != "disabled"
          hash[lower_bound] = lower_value
        end

        hash
      end
    end
  end
end
