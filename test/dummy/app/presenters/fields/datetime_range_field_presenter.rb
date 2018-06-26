# frozen_string_literal: true

module Fields
  class DatetimeRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      "#{record.start_time&.to_formatted_s} ~ #{record.finish_time&.to_formatted_s}"
    end

    def start_time_options
      {min: min_start_time, max: max_start_time, disabled: start_time_disabled?}.reject { |_, v| v.nil? }
    end

    def finish_time_options
      {min: min_finish_time, max: max_finish_time, disabled: finish_time_disabled?}.reject { |_, v| v.nil? }
    end

    private

    def start_time_disabled?
      access_readonly? || @model.options.fixed_start_time
    end

    def finish_time_disabled?
      access_readonly? || @model.options.fixed_finish_time
    end

    def min_start_time
      return if start_time_disabled?
      return if @model.options.start_from_unlimited?

      record = value
      if @model.options.start_from_now?
        record.start_time
      elsif @model.options.start_from_time?
        record.start_time
      elsif @model.options.start_from_minutes_before_finish? && @model.options.fixed_finish_time
        maximum_distance_minutes = @model.options.maximum_distance.minutes

        a = record.finish_time - @model.options.minutes_before_finish.minutes
        b = record.finish_time - maximum_distance_minutes

        a > b ? a : b
      end
    end

    def max_start_time
      return if start_time_disabled?

      record = value
      minimum_distance_minutes = @model.options.minimum_distance.minutes
      minimum_distance_minutes = 1.minute if minimum_distance_minutes == 0
      if @model.options.finish_to_now?
        record.finish_time - minimum_distance_minutes
      elsif @model.options.finish_to_time?
        @model.options.finish_time - minimum_distance_minutes
      end
    end

    def min_finish_time
      return if finish_time_disabled?

      record = value
      minimum_distance_minutes = @model.options.minimum_distance.minutes
      minimum_distance_minutes = 1.minute if minimum_distance_minutes == 0
      if @model.options.start_from_now?
        record.start_time + minimum_distance_minutes
      elsif @model.options.start_from_time?
        @model.options.start_time + minimum_distance_minutes
      end
    end

    def max_finish_time
      return if finish_time_disabled?
      return if @model.options.finish_to_unlimited?

      record = value
      if @model.options.finish_to_now?
        record.finish_time
      elsif @model.options.finish_to_time?
        @model.options.finish_time
      elsif @model.options.finish_to_minutes_since_start? && @model.options.fixed_start_time
        maximum_distance_minutes = @model.options.maximum_distance.minutes

        a = record.start_time + @model.options.minutes_before_finish.minutes
        b = record.start_time + maximum_distance_minutes

        a > b ? b : a
      end
    end
  end
end
