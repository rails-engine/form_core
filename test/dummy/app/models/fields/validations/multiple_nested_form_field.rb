# frozen_string_literal: true

module Fields::Validations
  class MultipleNestedFormField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Length
  end
end
