module Fields::Validations
  class IntegerField < ::OptionsModel
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Numericality
  end
end
