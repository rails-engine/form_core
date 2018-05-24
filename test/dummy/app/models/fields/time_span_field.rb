# frozen_string_literal: true

module Fields
  class TimeSpanField < Field
    serialize :validations, Validations::TimeSpanField
    serialize :options, Options::TimeSpanField

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      nested_model = Class.new(::Fields::TimeSpanField::TimeSpan)

      model.nested_models[name] = nested_model

      model.embeds_one name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    class TimeSpan < VirtualModel
      attribute :start_time, :datetime
      attribute :end_time, :datetime

      validates :end_time,
                timeliness: {
                  after: :start_time,
                  type: :datetime
                },
                allow_blank: true

      def start_time=(val)
        super(val.try(:in_time_zone))
      end

      def end_time=(val)
        super(val.try(:in_time_zone))
      end

      def start_time
        super&.to_time
      end

      def end_time
        super&.to_time
      end
    end
  end
end
