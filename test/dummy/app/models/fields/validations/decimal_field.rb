# frozen_string_literal: true

module Fields::Validations
  class DecimalField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Numericality
  end
end
