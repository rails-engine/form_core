# frozen_string_literal: true

module Fields
  class DatetimeRangeField < Field
    serialize :validations, Validations::DatetimeRangeField
    serialize :options, Options::DatetimeRangeField

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      nested_model = Class.new(::Fields::DatetimeRangeField::DatetimeRange)

      model.nested_models[name] = nested_model

      model.embeds_one name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    class DatetimeRange < VirtualModel
      attribute :start_time, :datetime
      attribute :finish_time, :datetime

      validates :start_time, :finish_time,
                presence: true

      validates :finish_time,
                timeliness: {
                  after: :start_time,
                  type: :datetime
                },
                allow_blank: false

      def start_time=(val)
        super(val.try(:in_time_zone))
      end

      def finish_time=(val)
        super(val.try(:in_time_zone))
      end

      def start_time
        super&.to_time
      end

      def finish_time
        super&.to_time
      end
    end
  end
end
