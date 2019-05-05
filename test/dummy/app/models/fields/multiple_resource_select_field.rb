# frozen_string_literal: true

module Fields
  class MultipleResourceSelectField < Field
    serialize :validations, Validations::MultipleResourceSelectField
    serialize :options, Options::MultipleResourceSelectField

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

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      model.attribute name, stored_type, default: [], array_without_blank: true
      model.attr_readonly name if accessibility == :readonly

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    protected

      def interpret_extra_to(model, accessibility, overrides = {})
        super
        return if accessibility != :read_and_write || !options.strict_select

        # TODO: performance
        # model.validates name, subset: {in: collection}, allow_blank: true
      end
  end
end
