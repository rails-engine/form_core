# frozen_string_literal: true

module Fields
  class IndexSelectFieldPresenter < FieldPresenter
    delegate :collection, to: :@model, allow_nil: false

    def value_for_preview
      index = super
      collection[super] if index
    end
  end
end
