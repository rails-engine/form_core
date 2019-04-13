# frozen_string_literal: true

module Fields::Validations
  class MultipleResourceField < FieldOptions
    prepend Fields::Validations::Presence
    prepend Fields::Validations::Length
  end
end
