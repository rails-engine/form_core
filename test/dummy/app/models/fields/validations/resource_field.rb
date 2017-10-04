# frozen_string_literal: true

module Fields::Validations
  class ResourceField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
