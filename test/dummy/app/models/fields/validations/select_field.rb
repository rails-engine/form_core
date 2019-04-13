# frozen_string_literal: true

module Fields::Validations
  class SelectField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
