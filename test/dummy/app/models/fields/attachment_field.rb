# frozen_string_literal: true

module Fields
  class AttachmentField < Field
    serialize :validations, Validations::AttachmentField
    serialize :options, NonConfigurable

    def stored_type
      :integer
    end

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      model.attribute name, stored_type
      model.has_one_attached name
      model.attr_readonly name if accessibility == :readonly

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end
  end
end
