# frozen_string_literal: true

module Fields::Validations
  class BooleanField < FieldOptions
    prepend Fields::Validations::Acceptance
  end
end
