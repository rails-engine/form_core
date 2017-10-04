module Fields
  class VariableLengthNestedFormFieldPresenter < FieldPresenter
    def name
      @model.pluralized_name
    end
  end
end
