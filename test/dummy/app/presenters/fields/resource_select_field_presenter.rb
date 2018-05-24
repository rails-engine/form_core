# frozen_string_literal: true

module Fields
  class ResourceSelectFieldPresenter < FieldPresenter
    def include_blank?
      required?
    end

    def can_custom_value?
      !@model.options.strict_select
    end

    def collection
      values = @model.collection

      if can_custom_value? && value.present?
        ([value] + values).uniq
      else
        values
      end
    end

    def options_for_select
      @view.options_for_select(collection, value)
    end
  end
end
