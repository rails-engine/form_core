module Fields::Validations
  class MultipleSelectField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Length
  end
end
