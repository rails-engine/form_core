module Fields::Options
  class IntegerField < FieldOptions
    attribute :step, :integer, default: 0

    validates :step,
              numericality: {
                greater_than_or_equal_to: 0
              }
  end
end
