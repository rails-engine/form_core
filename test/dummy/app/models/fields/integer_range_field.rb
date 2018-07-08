# frozen_string_literal: true

module Fields
  class IntegerRangeField < Field
    serialize :validations, Validations::IntegerRangeField
    serialize :options, Options::IntegerRangeField

    def interpret_to(model, overrides: {})
      check_model_validity!(model)

      accessibility = overrides.fetch(:accessibility, self.accessibility)
      return model if accessibility == :hidden

      nested_model = Class.new(::Fields::IntegerRangeField::IntegerRange)

      model.nested_models[name] = nested_model

      model.embeds_one name, anonymous_class: nested_model, validate: true
      model.accepts_nested_attributes_for name, reject_if: :all_blank

      interpret_validations_to model, accessibility, overrides
      interpret_extra_to model, accessibility, overrides

      model
    end

    class IntegerRange < VirtualModel
      attribute :start, :integer
      attribute :finish, :integer

      validates :start, :finish,
                presence: true,
                numericality: {only_integer: true}

      validates :finish,
                numericality: {
                  greater_than: :start
                },
                allow_blank: false
    end
  end
end
