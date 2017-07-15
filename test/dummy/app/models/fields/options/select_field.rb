module Fields::Options
  class SelectField < FieldOptions
    attribute :strict_select, :boolean, default: true
    attribute :collection, :string, default: [], array: true
  end
end
