# frozen_string_literal: true

module Fields::Validations
  class DateRangeField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
