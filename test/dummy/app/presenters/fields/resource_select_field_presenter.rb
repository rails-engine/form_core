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
      values =
        if @model.collection
          # TODO: limit 100 for performance
          @model.collection.limit(100).map(&@model.data_source.text_method)
        else
          []
        end

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
