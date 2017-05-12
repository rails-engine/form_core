module Fields::Validations
  class VariableLengthNestedFormField < ::OptionsModel
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Length
  end
end
