# frozen_string_literal: true

module Fields::Validations
  class MultipleChoiceField < FieldOptions
    prepend Fields::Validations::Presence
    prepend Fields::Validations::Length
  end
end
