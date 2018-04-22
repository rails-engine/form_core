# frozen_string_literal: true

module Fields
  class TimeSpanFieldPresenter < FieldPresenter
    def value
      raise "Can't read value directly"
    end

    def value_for_preview
      time_span = target&.send(@model.name)
      return unless time_span

      "#{time_span.start_time&.to_formatted_s} ~ #{time_span.end_time&.to_formatted_s}"
    end
  end
end
