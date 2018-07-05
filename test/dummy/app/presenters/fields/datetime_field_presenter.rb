# frozen_string_literal: true

module Fields
  class DatetimeFieldPresenter < FieldPresenter
    def value
      super&.in_time_zone
    end

    def value_for_preview
      value = self.value
      I18n.l(value) if value
    end

    def field_options
      return {} if access_readonly?

      options = {}
      current_time = Time.zone.now.change(sec: 0, usec: 0)

      if @model.options.start_from_now?
        start_minutes_offset = @model.options.start_from_now_minutes_offset.minutes.to_i
        options[:min] = current_time + start_minutes_offset
      elsif @model.options.start_from_time?
        options[:min] = @model.options.start
      elsif @model.options.start_from_minutes_before_finish?
        minutes_before_finish = @model.options.minutes_before_finish.minutes
        if @model.options.finish_to_now?
          finish_minutes_offset = @model.options.finish_to_now_minutes_offset.minutes.to_i
          options[:min] = current_time + finish_minutes_offset - minutes_before_finish
        elsif @model.options.finish_to_time?
          options[:min] = @model.options.finish - minutes_before_finish
        end
      end

      if @model.options.finish_to_now?
        finish_minutes_offset = @model.options.finish_to_now_minutes_offset.minutes.to_i
        options[:max] = current_time + finish_minutes_offset
      elsif @model.options.finish_to_time?
        options[:max] = @model.options.finish
      elsif @model.options.finish_to_minutes_since_start?
        minutes_since_start = @model.options.minutes_since_start.minutes.to_i
        if @model.options.start_from_now?
          start_minutes_offset = @model.options.start_from_now_minutes_offset.minutes.to_i
          options[:max] = current_time + start_minutes_offset + minutes_since_start
        elsif @model.options.start_from_time?
          options[:max] = @model.options.start + minutes_since_start
        end
      end

      options
    end
  end
end
