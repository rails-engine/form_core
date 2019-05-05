# frozen_string_literal: true

module Fields
  class DateRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      from =
        (I18n.l(record.begin.in_time_zone.to_date) if record.begin && record.begin != -Float::INFINITY)
      to =
        (I18n.l(record.end.in_time_zone.to_date) if record.end && record.end != Float::INFINITY)

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
        if @model.options.begin_from_today?
          record.begin
        elsif @model.options.begin_from_date?
          record.begin
        elsif @model.options.begin_from_days_before_end? && @model.options.fixed_end
          maximum_distance_days = @model.options.maximum_distance.days

          a = record.end - @model.options.days_before_end.days
          b = record.end - maximum_distance_days

          a > b ? a : b
        end
      end

      def max_begin
        return if begin_disabled?

        record = value
        minimum_distance_days = @model.options.minimum_distance.days
        minimum_distance_days = 1.minute if minimum_distance_days.zero?
        if @model.options.end_to_today?
          record.end - minimum_distance_days
        elsif @model.options.end_to_date?
          @model.options.end - minimum_distance_days
        end
      end

      def min_end
        return if end_disabled?

        record = value
        minimum_distance_days = @model.options.minimum_distance.days
        minimum_distance_days = 1.minute if minimum_distance_days.zero?
        if @model.options.begin_from_today?
          record.begin + minimum_distance_days
        elsif @model.options.begin_from_date?
          @model.options.begin + minimum_distance_days
        end
      end

      def max_end
        return if end_disabled?
        return if @model.options.end_to_unlimited?

        record = value
        if @model.options.end_to_today?
          record.end
        elsif @model.options.end_to_date?
          @model.options.end
        elsif @model.options.end_to_days_since_begin? && @model.options.fixed_begin
          maximum_distance_days = @model.options.maximum_distance.days

          a = record.begin + @model.options.days_before_end.days
          b = record.begin + maximum_distance_days

          a > b ? b : a
        end
      end
  end
end
