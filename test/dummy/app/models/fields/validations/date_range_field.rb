# frozen_string_literal: true

module Fields::Validations
  class DateRangeField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
