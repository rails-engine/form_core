# frozen_string_literal: true

module Fields
  class ResourceField < Field
    serialize :options, Options::ResourceField
    serialize :validations, Validations::ResourceField

    def stored_type
      :integer
    end

    def data_source
      options.data_source
    end

    def collection
      data_source.scoped_records
    end

    def attached_data_source?
      true
    end

    protected

    def interpret_extra_to(model, accessibility, overrides = {})
      super
      return if accessibility != :read_and_write

      # TODO: performance
      # model.validates name, inclusion: {in: collection}, allow_blank: true
    end
  end
end
