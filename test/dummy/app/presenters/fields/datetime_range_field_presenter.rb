# frozen_string_literal: true

module Fields
  class DatetimeRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      from =
        (I18n.l(record.begin.in_time_zone) if record.begin && record.begin != -Float::INFINITY)
      to =
        (I18n.l(record.end.in_time_zone) if record.end && record.end != Float::INFINITY)

      [from, to].join(" ~ ")
    end

    def begin_options
      { min: min_begin, max: max_begin, disabled: begin_disabled? }.reject { |_, v| v.nil? }
    end

    def end_options
      { min: min_end, max: max_end, disabled: end_disabled?, required: end_disabled? }.reject { |_, v| v.nil? }
    end

    private

      def end_required?
        !@model.options.nullable_end
      end

      def begin_disabled?
        access_readonly? || @model.options.fixed_begin
      end

      def end_disabled?
        access_readonly? || @model.options.fixed_end
      end

      def min_begin
        return if begin_disabled?
        return if @model.options.begin_from_unlimited?

        record = value
        if @model.options.begin_from_now?
          record.begin
        elsif @model.options.begin_from_time?
          record.begin
        elsif @model.options.begin_from_minutes_before_end? && @model.options.fixed_end
          maximum_distance_minutes = @model.options.maximum_distance.minutes

          a = record.end - @model.options.minutes_before_end.minutes
          b = record.end - maximum_distance_minutes

          a > b ? a : b
        end
      end

      def max_begin
        return if begin_disabled?

        record = value
        minimum_distance_minutes = @model.options.minimum_distance.minutes
        minimum_distance_minutes = 1.minute if minimum_distance_minutes.zero?
        if @model.options.end_to_now?
          record.end - minimum_distance_minutes
        elsif @model.options.end_to_time?
          @model.options.end - minimum_distance_minutes
        end
      end

      def min_end
        return if end_disabled?

        record = value
        minimum_distance_minutes = @model.options.minimum_distance.minutes
        minimum_distance_minutes = 1.minute if minimum_distance_minutes.zero?
        if @model.options.begin_from_now?
          record.begin + minimum_distance_minutes
        elsif @model.options.begin_from_time?
          @model.options.begin + minimum_distance_minutes
        end
      end

      def max_end
        return if end_disabled?
        return if @model.options.end_to_unlimited?

        record = value
        if @model.options.end_to_now?
          record.end
        elsif @model.options.end_to_time?
          @model.options.end
        elsif @model.options.end_to_minutes_since_begin? && @model.options.fixed_begin
          maximum_distance_minutes = @model.options.maximum_distance.minutes

          a = record.begin + @model.options.minutes_before_end.minutes
          b = record.begin + maximum_distance_minutes

          a > b ? b : a
        end
      end
  end
end
