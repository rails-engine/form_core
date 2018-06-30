# frozen_string_literal: true

module Fields
  class DateFieldPresenter < FieldPresenter
    def value_for_preview
      value = super
      I18n.l(value) if value
    end

    def field_options
      return {} if access_readonly?

      options = {}
      current_date = Time.zone.today

      if @model.options.start_from_today?
        start_date_days_offset = @model.options.start_from_today_days_offset.days
        options[:min] = current_date + start_date_days_offset
      elsif @model.options.start_from_date?
        options[:min] = @model.options.start_date
      elsif @model.options.start_from_days_before_finish?
        days_before_finish = @model.options.days_before_finish.days
        if @model.options.finish_to_today?
          finish_date_days_offset = @model.options.finish_to_today_days_offset.days
          options[:min] = current_date + finish_date_days_offset - days_before_finish
        elsif @model.options.finish_to_date?
          options[:min] = @model.options.finish_date - days_before_finish
        end
      end

      if @model.options.finish_to_today?
        finish_date_days_offset = @model.options.finish_to_today_days_offset.days
        options[:max] = current_date + finish_date_days_offset
      elsif @model.options.finish_to_date?
        options[:max] = @model.options.finish_date
      elsif @model.options.finish_to_days_since_start?
        days_since_start = @model.options.days_since_start.days
        if @model.options.start_from_today?
          start_date_days_offset = @model.options.start_from_today_days_offset.days
          options[:max] = current_date + start_date_days_offset + days_since_start
        elsif @model.options.start_from_date?
          options[:max] = @model.options.start_date + days_since_start
        end
      end

      options
    end
  end
end
