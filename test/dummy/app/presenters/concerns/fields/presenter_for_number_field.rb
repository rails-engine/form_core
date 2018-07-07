# frozen_string_literal: true

module Concerns::Fields
  module PresenterForNumberField
    extend ActiveSupport::Concern

    def min
      return if @model.validations.numericality.lower_bound_check_disabled?

      min = @model.validations.numericality.lower_bound_value
      integer_only? ? min.to_i : min
    end

    def max
      return if @model.validations.numericality.upper_bound_check_disabled?

      max = @model.validations.numericality.upper_bound_value
      integer_only? ? max.to_i : max
    end

    def step
      step = @model.options.step
      return if step.zero?

      integer_only? ? step.to_i : step
    end

    def integer_only?
      false
    end

    def to_builder_options
      {min: min, max: max, step: step, required: required?}.reject { |_, v| v.blank? }
    end
  end
end
