module Fields::Options
  class SelectField < ::OptionsModel
    attribute :strict_select, :boolean, default: true
    attribute :collection, :string, default: [], array: true
  end
end
