module Fields::Options
  class ResourceSelectField < FieldOptions
    include Concerns::Fields::Options::DataSource

    attribute :strict_select, :boolean, default: true
  end
end
