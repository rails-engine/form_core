# frozen_string_literal: true

module Fields::Validations
  class NestedFormField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
