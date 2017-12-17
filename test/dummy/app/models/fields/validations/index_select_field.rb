# frozen_string_literal: true

module Fields::Validations
  class IndexSelectField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
