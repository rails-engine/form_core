# frozen_string_literal: true

module Fields::Validations
  class DateField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
