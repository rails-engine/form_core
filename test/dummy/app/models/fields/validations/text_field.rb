# frozen_string_literal: true

module Fields::Validations
  class TextField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Length
    prepend Concerns::Fields::Validations::Format
  end
end
