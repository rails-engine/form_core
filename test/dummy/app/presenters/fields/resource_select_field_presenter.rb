module Fields
  class ResourceSelectFieldPresenter < FieldPresenter
    def include_blank?
      !@model.validations.presence?
    end

    def can_custom_value?
      !@model.options.strict_select?
    end

    def collection
      values = @model.collection.map(&@model.data_source.text_method)

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
