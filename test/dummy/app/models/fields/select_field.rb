# frozen_string_literal: true

module Fields
  class SelectField < Field
    serialize :validations, Validations::SelectField
    serialize :options, Options::SelectField

    def stored_type
      :string
    end

    def collection
      options.collection
    end

    protected

    def interpret_extra_to(model, accessibility, overrides = {})
      super
      return if accessibility != :editable || !options.strict_select
      model.validates name, inclusion: {in: collection}, allow_blank: true
    end
  end
end
