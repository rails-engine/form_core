module Fields::Validations
  class BooleanField < ::OptionsModel
    prepend Concerns::Fields::Validations::Acceptance
  end
end
