# frozen_string_literal: true

module Fields::Validations
  class ChoiceField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
