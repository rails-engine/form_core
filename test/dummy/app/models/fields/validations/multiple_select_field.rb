# frozen_string_literal: true

module Fields::Validations
  class MultipleSelectField < FieldOptions
    prepend Fields::Validations::Presence
    prepend Fields::Validations::Length
  end
end
