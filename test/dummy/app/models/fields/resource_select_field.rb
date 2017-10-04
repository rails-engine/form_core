# frozen_string_literal: true

module Fields
  class ResourceSelectField < SelectField
    serialize :options, Options::ResourceSelectField

    def stored_type
      :string
    end

    def data_source
      options.data_source
    end

    def collection
      data_source.scoped_records
    end
  end
end
