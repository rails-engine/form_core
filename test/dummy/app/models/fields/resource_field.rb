# frozen_string_literal: true

module Fields
  class ResourceField < Field
    serialize :validations, Validations::ResourceField
    serialize :options, Options::ResourceField

    def stored_type
      data_source.stored_type || :string
    end

    def data_source
      options.data_source
    end

    def foreign_field_name
      data_source.foreign_field_name(name)
    end

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      default_value = overrides.fetch(:default_value, self.default_value)
      model.attribute foreign_field_name, stored_type, default: default_value

      if accessibility == :readonly
        model.attr_readonly foreign_field_name
      end

      data_source.interpret_to model, name, accessibility
      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end
  end
end
