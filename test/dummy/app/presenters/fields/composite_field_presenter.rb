# frozen_string_literal: true

module Fields
  class CompositeFieldPresenter < FieldPresenter
    def value
      target&.send(@model.name)
    end

    def value_for_preview
      target&.send(@model.name)
    end
  end
end
