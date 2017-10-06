# frozen_string_literal: true

module Fields
  class DatetimeField < Field
    serialize :validations, Validations::DatetimeField
    serialize :options, Options::DatetimeField

    def stored_type
      :datetime
    end
  end
end
