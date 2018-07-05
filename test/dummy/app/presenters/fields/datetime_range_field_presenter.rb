# frozen_string_literal: true

module Fields
  class DatetimeRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      "#{I18n.l(record.start.in_time_zone) if record.start} ~ #{I18n.l(record.finish.in_time_zone) if record.finish}"
    end

    def start_options
      {min: min_start, max: max_start, disabled: start_disabled?}.reject { |_, v| v.nil? }
    end

    def finish_options
      {min: min_finish, max: max_finish, disabled: finish_disabled?}.reject { |_, v| v.nil? }
    end

    private

    def start_disabled?
      access_readonly? || @model.options.fixed_start
    end

    def finish_disabled?
      access_readonly? || @model.options.fixed_finish
    end

    def min_start
      return if start_disabled?
      return if @model.options.start_from_unlimited?

      record = value
      if @model.options.start_from_now?
        record.start
      elsif @model.options.start_from_time?
        record.start
      elsif @model.options.start_from_minutes_before_finish? && @model.options.fixed_finish
        maximum_distance_minutes = @model.options.maximum_distance.minutes

        a = record.finish - @model.options.minutes_before_finish.minutes
        b = record.finish - maximum_distance_minutes

        a > b ? a : b
      end
    end

    def max_start
      return if start_disabled?

      record = value
      minimum_distance_minutes = @model.options.minimum_distance.minutes
      minimum_distance_minutes = 1.minute if minimum_distance_minutes == 0
      if @model.options.finish_to_now?
        record.finish - minimum_distance_minutes
      elsif @model.options.finish_to_time?
        @model.options.finish - minimum_distance_minutes
      end
    end

    def min_finish
      return if finish_disabled?

      record = value
      minimum_distance_minutes = @model.options.minimum_distance.minutes
      minimum_distance_minutes = 1.minute if minimum_distance_minutes == 0
      if @model.options.start_from_now?
        record.start + minimum_distance_minutes
      elsif @model.options.start_from_time?
        @model.options.start + minimum_distance_minutes
      end
    end

    def max_finish
      return if finish_disabled?
      return if @model.options.finish_to_unlimited?

      record = value
      if @model.options.finish_to_now?
        record.finish
      elsif @model.options.finish_to_time?
        @model.options.finish
      elsif @model.options.finish_to_minutes_since_start? && @model.options.fixed_start
        maximum_distance_minutes = @model.options.maximum_distance.minutes

        a = record.start + @model.options.minutes_before_finish.minutes
        b = record.start + maximum_distance_minutes

        a > b ? b : a
      end
    end
  end
end
