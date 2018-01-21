# frozen_string_literal: true

module Fields
  class VariableLengthNestedFormFieldPresenter < FieldPresenter
    def name
      @model.pluralized_name
    end

    def variable_length_nested_form?
      true
    end

    def value
      raise "Can't read value directly"
    end

    def value_for_preview
      target&.send(@model.name)
    end
  end
end
