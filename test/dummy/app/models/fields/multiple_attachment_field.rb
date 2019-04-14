# frozen_string_literal: true

module Fields
  class MultipleAttachmentField < Field
    serialize :validations, Validations::MultipleAttachmentField
    serialize :options, NonConfigurable

    def stored_type
      :integer
    end

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      model.attribute name, stored_type, default: [], array_without_blank: true
      model.has_many_attached name
      if accessibility == :readonly
        model.attr_readonly name
      end

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end
  end
end
