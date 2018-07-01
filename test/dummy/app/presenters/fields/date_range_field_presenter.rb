# frozen_string_literal: true

module Fields
  class DateRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      "#{record.start_date&.to_formatted_s} ~ #{record.finish_date&.to_formatted_s}"
    end

    def start_date_options
      {min: min_start_date, max: max_start_date, disabled: start_date_disabled?}.reject { |_, v| v.nil? }
    end

    def finish_date_options
      {min: min_finish_date, max: max_finish_date, disabled: finish_date_disabled?}.reject { |_, v| v.nil? }
    end

    private

    def start_date_disabled?
      access_readonly? || @model.options.fixed_start_date
    end

    def finish_date_disabled?
      access_readonly? || @model.options.fixed_finish_date
    end

    def min_start_date
      return if start_date_disabled?
      return if @model.options.start_from_unlimited?

      record = value
      if @model.options.start_from_today?
        record.start_date
      elsif @model.options.start_from_date?
        record.start_date
      elsif @model.options.start_from_days_before_finish? && @model.options.fixed_finish_date
        maximum_distance_days = @model.options.maximum_distance.days

        a = record.finish_date - @model.options.days_before_finish.days
        b = record.finish_date - maximum_distance_days

        a > b ? a : b
      end
    end

    def max_start_date
      return if start_date_disabled?

      record = value
      minimum_distance_days = @model.options.minimum_distance.days
      minimum_distance_days = 1.minute if minimum_distance_days == 0
      if @model.options.finish_to_today?
        record.finish_date - minimum_distance_days
      elsif @model.options.finish_to_date?
        @model.options.finish_date - minimum_distance_days
      end
    end

    def min_finish_date
      return if finish_date_disabled?

      record = value
      minimum_distance_days = @model.options.minimum_distance.days
      minimum_distance_days = 1.minute if minimum_distance_days == 0
      if @model.options.start_from_today?
        record.start_date + minimum_distance_days
      elsif @model.options.start_from_date?
        @model.options.start_date + minimum_distance_days
      end
    end

    def max_finish_date
      return if finish_date_disabled?
      return if @model.options.finish_to_unlimited?

      record = value
      if @model.options.finish_to_today?
        record.finish_date
      elsif @model.options.finish_to_date?
        @model.options.finish_date
      elsif @model.options.finish_to_days_since_start? && @model.options.fixed_start_date
        maximum_distance_days = @model.options.maximum_distance.days

        a = record.start_date + @model.options.days_before_finish.days
        b = record.start_date + maximum_distance_days

        a > b ? b : a
      end
    end
  end
end
