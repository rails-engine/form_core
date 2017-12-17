# frozen_string_literal: true

module Fields
  class IndexSelectFieldPresenter < FieldPresenter
    delegate :collection, to: :@model, allow_nil: false
  end
end
