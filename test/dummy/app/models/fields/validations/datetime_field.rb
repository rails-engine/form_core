# frozen_string_literal: true

module Fields::Validations
  class DatetimeField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
