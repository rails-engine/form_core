# frozen_string_literal: true

module Fields
  class MultipleChoiceField < Field
    serialize :validations, Validations::MultipleChoiceField
    serialize :options, Options::MultipleChoiceField

    def stored_type
      :integer
    end

    def attach_choices?
      true
    end

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      model.attribute name, stored_type, default: [], array_without_blank: true
      if accessibility == :readonly
        model.attr_readonly name
      end

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    protected

    def interpret_extra_to(model, accessibility, overrides = {})
      super
      return if accessibility != :read_and_write

      choice_ids = choices.map(&:id)
      return if choice_ids.empty?
      model.validates name, subset: {in: choice_ids}, allow_blank: true
    end
  end
end
