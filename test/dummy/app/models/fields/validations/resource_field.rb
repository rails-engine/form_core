# frozen_string_literal: true

module Fields::Validations
  class ResourceField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
