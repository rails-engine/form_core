# frozen_string_literal: true

module Fields
  class DateField < Field
    serialize :validations, Validations::DateField
    serialize :options, Options::DateField

    def stored_type
      :datetime
    end

    protected

      def interpret_extra_to(model, accessibility, overrides = {})
        super

        model.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(val)
          super(val.try(:in_time_zone)&.utc)
        end
        CODE
      end
  end
end
