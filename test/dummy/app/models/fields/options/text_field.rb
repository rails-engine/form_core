module Fields::Options
  class TextField < ::OptionsModel
    attribute :multiline, :boolean, default: false
  end
end
