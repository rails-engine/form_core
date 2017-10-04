# frozen_string_literal: true

module Fields
  class MultipleSelectField < Field
    serialize :validations, Validations::MultipleSelectField
    serialize :options, Options::SelectField

    def stored_type
      :string
    end

    def collection
      options.collection
    end

    def pluralized_name
      self[:name].pluralize.to_sym
    end

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      model.attribute pluralized_name, stored_type, default: [], array_without_blank: true

      if accessibility == :read_only
        model.attr_readonly pluralized_name
      end

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    protected

    def interpret_extra_to(model, accessibility, _overrides = {})
      return if accessibility != :editable || !options.strict_select?

      model.validates name, inclusion: {in: options.collection}, allow_blank: true
    end
  end
end
