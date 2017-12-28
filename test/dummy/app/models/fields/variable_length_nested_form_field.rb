# frozen_string_literal: true

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

      overrides.merge!(name: pluralized_name)

      nested_model = nested_form.to_virtual_model(overrides: {_global: {accessibility: accessibility}})

      model.nested_models[name] = nested_model

      model.embeds_many pluralized_name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for pluralized_name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end
  end
end
