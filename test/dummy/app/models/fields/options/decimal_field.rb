# frozen_string_literal: true

module Fields::Options
  class DecimalField < FieldOptions
    attribute :step, :decimal, default: 0.01

    validates :step,
              numericality: {
                greater_than_or_equal_to: 0.0
              }
  end
end
