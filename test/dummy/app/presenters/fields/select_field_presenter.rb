# frozen_string_literal: true

module Fields
  class SelectFieldPresenter < FieldPresenter
    def include_blank?
      !@model.validations.presence
    end

    def can_custom_value?
      !@model.options.strict_select
    end

    def collection
      if can_custom_value? && value.present?
        ([value] + @model.collection).uniq
      else
        @model.collection
      end
    end

    def options_for_select
      @view.options_for_select(collection, value)
    end
  end
end
