# frozen_string_literal: true

module Fields
  class DecimalRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      "#{record.begin} ~ #{record.end}"
    end

    def begin_options
      {min: min_begin, max: max_begin, disabled: begin_disabled?}.reject { |_, v| v.nil? }
    end

    def end_options
      {min: min_end, max: max_end, disabled: end_disabled?}.reject { |_, v| v.nil? }
    end

    private

    def begin_disabled?
      access_readonly? || @model.options.fixed_begin
    end

    def end_disabled?
      access_readonly? || @model.options.fixed_end
    end

    def min_begin
      return if begin_disabled?
      return if @model.options.begin_from_unrestricted?

      if @model.options.begin_from_value?
        if @model.options.fixed_end
          @model.options.end_value - maximum_gap_value
        else
          @model.options.begin_value
        end
      elsif @model.options.begin_from_offsets_before_end? && @model.options.fixed_end
        a = @model.options.end_value - @model.options.offsets_before_end
        b = @model.options.end_value - maximum_gap_value

        a > b ? a : b
      end
    end

    def max_begin
      return if begin_disabled?

      if @model.options.end_to_value?
        @model.options.end_value - minimum_gap_value
      end
    end

    def min_end
      return if end_disabled?

      if @model.options.begin_from_value?
        @model.options.begin_value + minimum_gap_value
      end
    end

    def max_end
      return if end_disabled?
      return if @model.options.end_to_unrestricted?

      if @model.options.end_to_value?
        if @model.options.fixed_begin
          @model.options.begin_value + maximum_gap_value
        else
          @model.options.end_value
        end
      elsif @model.options.end_to_offsets_since_begin? && @model.options.fixed_begin
        a = @model.options.begin_value + @model.options.offsets_before_end
        b = @model.options.begin_value + maximum_gap_value

        a > b ? b : a
      end
    end

    def maximum_gap_value
      if @model.options.maximum_gap_check_unrestricted?
        0
      elsif @model.options.maximum_gap_check_less_than?
        @model.options.maximum_gap_value - 1
      else
        @model.options.maximum_gap_value
      end
    end

    def minimum_gap_value
      if @model.options.minimum_gap_check_unrestricted?
        0
      elsif @model.options.minimum_gap_check_greater_than?
        @model.options.minimum_gap_value + 0.0001
      else
        @model.options.minimum_gap_value
      end
    end
  end
end
