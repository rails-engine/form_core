# frozen_string_literal: true

module Fields
  class ResourceFieldPresenter < FieldPresenter
    delegate :scoped_records, :value_method, :text_method, to: :data_source

    def include_blank?
      !@model.validations.presence
    end

    def options_for_select
      @view.options_from_collection_for_select(scoped_records, value_method, text_method, value)
    end

    def name
      @model.foreign_field_name
    end

    def value
      target&.read_attribute(foreign_field_name)
    end

    private

    def data_source
      @model.data_source
    end
  end
end
