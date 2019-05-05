# frozen_string_literal: true

module Fields
  class ResourceSelectField < Field
    serialize :options, Options::ResourceSelectField
    serialize :validations, Validations::ResourceSelectField

    def stored_type
      :string
    end

    delegate :data_source, to: :options

    def collection
      data_source.scoped_records
    end

    def attached_data_source?
      true
    end

    protected

      def interpret_extra_to(model, accessibility, overrides = {})
        super
        return if accessibility != :read_and_write || !options.strict_select

        # TODO: performance
        # model.validates name, inclusion: {in: collection}, allow_blank: true
      end
  end
end
