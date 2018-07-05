# frozen_string_literal: true

module Fields
  class DateRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      "#{I18n.l(record.start.in_time_zone.to_date) if record.start} ~ #{I18n.l(record.finish.in_time_zone.to_date) if record.finish}"
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
      if @model.options.start_from_today?
        record.start
      elsif @model.options.start_from_date?
        record.start
      elsif @model.options.start_from_days_before_finish? && @model.options.fixed_finish
        maximum_distance_days = @model.options.maximum_distance.days

        a = record.finish - @model.options.days_before_finish.days
        b = record.finish - maximum_distance_days

        a > b ? a : b
      end
    end

    def max_start
      return if start_disabled?

      record = value
      minimum_distance_days = @model.options.minimum_distance.days
      minimum_distance_days = 1.minute if minimum_distance_days == 0
      if @model.options.finish_to_today?
        record.finish - minimum_distance_days
      elsif @model.options.finish_to_date?
        @model.options.finish - minimum_distance_days
      end
    end

    def min_finish
      return if finish_disabled?

      record = value
      minimum_distance_days = @model.options.minimum_distance.days
      minimum_distance_days = 1.minute if minimum_distance_days == 0
      if @model.options.start_from_today?
        record.start + minimum_distance_days
      elsif @model.options.start_from_date?
        @model.options.start + minimum_distance_days
      end
    end

    def max_finish
      return if finish_disabled?
      return if @model.options.finish_to_unlimited?

      record = value
      if @model.options.finish_to_today?
        record.finish
      elsif @model.options.finish_to_date?
        @model.options.finish
      elsif @model.options.finish_to_days_since_start? && @model.options.fixed_start
        maximum_distance_days = @model.options.maximum_distance.days

        a = record.start + @model.options.days_before_finish.days
        b = record.start + maximum_distance_days

        a > b ? b : a
      end
    end
  end
end
