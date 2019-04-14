# frozen_string_literal: true

module Fields::Validations
  class ResourceSelectField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
