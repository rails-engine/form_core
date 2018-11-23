# frozen_string_literal: true

module Fields
  class MultipleSelectField < Field
    serialize :validations, Validations::MultipleSelectField
    serialize :options, Options::MultipleSelectField

    def stored_type
      :string
    end

    def attached_choices?
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
      return if accessibility != :read_and_write || !options.strict_select

      model.validates name, subset: {in: choices.map(&:label)}, allow_blank: true
    end
  end
end
