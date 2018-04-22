# frozen_string_literal: true

module Fields::Options
  class TimeSpanField < FieldOptions
    attribute :start_at_least_time, :datetime
    attribute :end_at_most_time, :datetime

    validates :end_at_most_time,
              timeliness: {
                after: :start_at_least_time,
                type: :datetime
              },
              allow_blank: true

    def interpret_to(model, field_name, _accessibility, _options = {})
      time_span_model = model.nested_models[field_name]
      if start_at_least_time.present?
        time_span_model.validates :start_time,
                                  timeliness: {
                                    on_or_after: start_at_least_time.dup,
                                    type: :datetime
                                  },
                                  allow_blank: true
      end

      if end_at_most_time.present?
        time_span_model.validates :end_time,
                                  timeliness: {
                                    on_or_before: end_at_most_time.dup,
                                    type: :datetime
                                  },
                                  allow_blank: true
      end
    end
  end
end
