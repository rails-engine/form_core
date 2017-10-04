# frozen_string_literal: true

module Fields
  class TextFieldPresenter < FieldPresenter
    def multiline
      @model.options.multiline
    end
    alias_method :multiline?, :multiline
  end
end
