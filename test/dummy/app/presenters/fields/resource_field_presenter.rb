# frozen_string_literal: true

module Fields
  class ResourceFieldPresenter < FieldPresenter
    def value_for_preview
      return unless @model.collection
      return if @model.collection.none?

      id = value
      return unless id.present?

      collection
        .where(@model.data_source.value_method => id)
        .first
        &.send(@model.data_source.text_method)
    end

    def include_blank?
      required?
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
  end
end
