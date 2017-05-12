module Fields::Validations
  class ResourceField < ::OptionsModel
    prepend Concerns::Fields::Validations::Presence
  end
end
