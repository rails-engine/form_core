# frozen_string_literal: true

module Fields::Validations
  class ChoiceField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
