# frozen_string_literal: true

module Fields::Validations
  class MultipleNestedFormField < FieldOptions
    prepend Fields::Validations::Presence
    prepend Fields::Validations::Length
  end
end
