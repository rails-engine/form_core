# frozen_string_literal: true

module Fields::Options
  class IntegerField < FieldOptions
    attribute :step, :integer, default: 0

    validates :step,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0
              }
  end
end
