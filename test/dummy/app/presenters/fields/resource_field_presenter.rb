# frozen_string_literal: true

module Fields
  class ResourceFieldPresenter < FieldPresenter
    delegate :scoped_records, :value_method, :text_method, :value_for_preview_method, to: :data_source

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

    def value_for_preview
      target.send(@model.name)&.read_attribute(value_for_preview_method.to_s)
    end

    def access_readonly?
      target.class.attr_readonly?(name)
    end

    def access_hidden?
      target.class.attribute_names.exclude?(name.to_s) && target.class._reflections.keys.exclude?(name.to_s)
    end

    def access_read_and_write
      target.class.attribute_names.include?(name.to_s) || target.class._reflections.keys.include?(name.to_s)
    end

    private

    def data_source
      @model.data_source
    end
  end
end
