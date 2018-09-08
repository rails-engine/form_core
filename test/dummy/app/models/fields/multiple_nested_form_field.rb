# frozen_string_literal: true

module Fields
  class MultipleNestedFormField < Field
    has_one :nested_form, as: :attachable, dependent: :destroy

    after_create do
      build_nested_form.save!
    end

    serialize :validations, Validations::MultipleNestedFormField
    serialize :options, Options::MultipleNestedFormField

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      overrides[:name] = name

      nested_model = nested_form.to_virtual_model(overrides: {_global: {accessibility: accessibility}})

      model.nested_models[name] = nested_model

      model.embeds_many name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end
  end
end
