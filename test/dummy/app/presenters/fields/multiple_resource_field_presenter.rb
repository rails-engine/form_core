# frozen_string_literal: true

module Fields
  class MultipleResourceFieldPresenter < FieldPresenter
    MAX_HARD_CODE_ITEMS_SIZE = 20

    def include_blank?
      required?
    end

    def value_for_preview
      return unless @model.collection
      return if @model.collection.none?

      collection
        .where(@model.data_source.value_method => value)
        .map(&@model.data_source.text_method)
        .join(", ")
    end

    def collection
      return unless @model.collection

      # TODO: limit 100 for performance
      @model.collection.limit(100)
    end

    def options_for_select
      unless @model.collection
        return @view.options_for_select([])
      end

      @view.options_from_collection_for_select(
        collection, @model.data_source.value_method, @model.data_source.text_method, value
      )
    end

    def max_items_size
      size = @model.validations.length.maximum
      size > 0 ? size : MAX_HARD_CODE_ITEMS_SIZE
    end
  end
end
