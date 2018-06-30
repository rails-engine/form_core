# frozen_string_literal: true

module Fields
  class DateRangeField < Field
    serialize :validations, Validations::DateRangeField
    serialize :options, Options::DateRangeField

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      nested_model = Class.new(::Fields::DateRangeField::DateRange)

      model.nested_models[name] = nested_model

      model.embeds_one name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    class DateRange < VirtualModel
      attribute :start_date, :datetime
      attribute :finish_date, :datetime

      validates :start_date, :finish_date,
                presence: true

      validates :finish_date,
                timeliness: {
                  after: :start_date,
                  type: :date
                },
                allow_blank: false

      def start_date=(val)
        super(val.try(:in_time_zone)&.utc)
      end

      def finish_date=(val)
        super(val.try(:in_time_zone)&.utc)
      end
    end
  end
end
