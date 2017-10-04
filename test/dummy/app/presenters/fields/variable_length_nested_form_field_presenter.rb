# frozen_string_literal: true

module Fields
  class VariableLengthNestedFormFieldPresenter < FieldPresenter
    def name
      @model.pluralized_name
    end
  end
end
