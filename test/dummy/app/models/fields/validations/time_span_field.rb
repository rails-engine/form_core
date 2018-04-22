# frozen_string_literal: true

module Fields::Validations
  class TimeSpanField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
