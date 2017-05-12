module Fields::Validations
  class SelectField < ::OptionsModel
    prepend Concerns::Fields::Validations::Presence
  end
end
