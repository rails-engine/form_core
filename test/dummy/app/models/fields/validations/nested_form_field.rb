# frozen_string_literal: true

module Fields::Validations
  class NestedFormField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
