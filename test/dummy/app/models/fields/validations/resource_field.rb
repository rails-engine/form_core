module Fields::Validations
  class ResourceField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
