module Fields::Validations
  class TextField < ::OptionsModel
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Length
    prepend Concerns::Fields::Validations::Format
  end
end
