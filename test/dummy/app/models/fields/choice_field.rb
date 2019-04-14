# frozen_string_literal: true

module Fields
  class ChoiceField < Field
    serialize :validations, Validations::ChoiceField
    serialize :options, NonConfigurable

    def stored_type
      :integer
    end

    def attached_choices?
      true
    end

    protected

    def interpret_extra_to(model, accessibility, overrides = {})
      super
      return if accessibility != :read_and_write

      choice_ids = choices.pluck(:id)
      return if choice_ids.empty?

      model.validates name, inclusion: {in: choice_ids}, allow_blank: true
    end
  end
end
