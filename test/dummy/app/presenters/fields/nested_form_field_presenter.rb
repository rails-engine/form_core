# frozen_string_literal: true

module Fields
  class NestedFormFieldPresenter < FieldPresenter
    def nested_form_field?
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
