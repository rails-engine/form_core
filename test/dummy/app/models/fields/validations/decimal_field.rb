module Fields::Validations
  class DecimalField < ::OptionsModel
    prepend Concerns::Fields::Validations::Presence
    prepend Concerns::Fields::Validations::Numericality
  end
end
