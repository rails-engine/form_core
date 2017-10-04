module Fields
  class VariableLengthNestedFormField < Field
    has_one :nested_form, as: :attachable, dependent: :destroy

    after_create do
      create_nested_form
    end

    serialize :validations, Validations::VariableLengthNestedFormField
    serialize :options, Options::VariableLengthNestedFormField

    def pluralized_name
      self[:name].pluralize.to_sym
    end

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      nested_model = nested_form.to_virtual_model

      model.nested_models[name] = nested_model

      model.has_many pluralized_name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for pluralized_name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    protected

    def interpret_validations_to(model, accessibility, overrides = {})
      validations_overrides = overrides.fetch(:validations) { {} }
      validations =
        if validations_overrides.any?
          self.validations.dup.update(validations_overrides)
        else
          self.validations
        end

      validations.interpret_to(model, pluralized_name, accessibility)
    end

    def interpret_extra_to(model, accessibility, overrides = {})
      options_overrides = overrides.fetch(:options) { {} }
      options =
        if options_overrides.any?
          self.options.dup.update(options_overrides)
        else
          self.options
        end

      options.interpret_to(model, pluralized_name, accessibility)
    end
  end
end
