# frozen_string_literal: true

module Fields
  class IntegerRangeFieldPresenter < CompositeFieldPresenter
    def value_for_preview
      record = value
      return unless record

      "#{record.start} ~ #{record.finish}"
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
      return if @model.options.start_from_unrestricted?

      if @model.options.start_from_value?
        if @model.options.fixed_finish
          @model.options.finish_value - maximum_gap_value
        else
          @model.options.start_value
        end
      elsif @model.options.start_from_offsets_before_finish? && @model.options.fixed_finish
        a = @model.options.finish_value - @model.options.offsets_before_finish
        b = @model.options.finish_value - maximum_gap_value

        a > b ? a : b
      end
    end

    def max_start
      return if start_disabled?

      if @model.options.finish_to_value?
        @model.options.finish_value - minimum_gap_value
      end
    end

    def min_finish
      return if finish_disabled?

      if @model.options.start_from_value?
        @model.options.start_value + minimum_gap_value
      end
    end

    def max_finish
      return if finish_disabled?
      return if @model.options.finish_to_unrestricted?

      if @model.options.finish_to_value?
        if @model.options.fixed_start
          @model.options.start_value + maximum_gap_value
        else
          @model.options.finish_value
        end
      elsif @model.options.finish_to_offsets_since_start? && @model.options.fixed_start
        a = @model.options.start_value + @model.options.offsets_before_finish
        b = @model.options.start_value + maximum_gap_value

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
        @model.options.minimum_gap_value + 1
      else
        @model.options.minimum_gap_value
      end
    end
  end
end
