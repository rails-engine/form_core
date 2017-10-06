# frozen_string_literal: true

module Fields::Validations
  class DatetimeField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
