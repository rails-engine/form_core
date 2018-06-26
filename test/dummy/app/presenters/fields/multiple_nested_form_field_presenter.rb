# frozen_string_literal: true

module Fields
  class MultipleNestedFormFieldPresenter < CompositeFieldPresenter
    def multiple_nested_form?
      true
    end
  end
end
