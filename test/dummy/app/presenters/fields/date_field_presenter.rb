# frozen_string_literal: true

module Fields
  class DateFieldPresenter < FieldPresenter
    def value
      super&.in_time_zone&.to_date
    end

    def value_for_preview
      value = self.value
      I18n.l(value) if value
    end

    def field_options
      return {} if access_readonly?

      options = {}
      current_date = Time.zone.today

      if @model.options.begin_from_today?
        begin_days_offset = @model.options.begin_from_today_days_offset.days
        options[:min] = current_date + begin_days_offset
      elsif @model.options.begin_from_date?
        options[:min] = @model.options.begin
      elsif @model.options.begin_from_days_before_end?
        days_before_end = @model.options.days_before_end.days
        if @model.options.end_to_today?
          end_days_offset = @model.options.end_to_today_days_offset.days
          options[:min] = current_date + end_days_offset - days_before_end
        elsif @model.options.end_to_date?
          options[:min] = @model.options.end - days_before_end
        end
      end

      if @model.options.end_to_today?
        end_days_offset = @model.options.end_to_today_days_offset.days
        options[:max] = current_date + end_days_offset
      elsif @model.options.end_to_date?
        options[:max] = @model.options.end
      elsif @model.options.end_to_days_since_begin?
        days_since_begin = @model.options.days_since_begin.days
        if @model.options.begin_from_today?
          begin_days_offset = @model.options.begin_from_today_days_offset.days
          options[:max] = current_date + begin_days_offset + days_since_begin
        elsif @model.options.begin_from_date?
          options[:max] = @model.options.begin + days_since_begin
        end
      end

      options
    end
  end
end
