# frozen_string_literal: true

module Fields::Validations
  class DatetimeRangeField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
