# frozen_string_literal: true

module Fields
  class NestedFormFieldPresenter < CompositeFieldPresenter
    def nested_form_field?
      true
    end
  end
end
