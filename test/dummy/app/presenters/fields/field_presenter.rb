# frozen_string_literal: true

class Fields::FieldPresenter < ApplicationPresenter
  def required
    @model.validations&.presence
  end
  alias_method :required?, :required

  def target
    @options[:target]
  end

  def value
    target&.read_attribute(@model.name)
  end

  def value_for_preview
    target&.read_attribute(@model.name)
  end

  def access_readonly?
    target.class.attr_readonly?(@model.name)
  end

  def access_hidden?
    target.class.attribute_names.exclude?(@model.name.to_s) && target.class._reflections.keys.exclude?(@model.name.to_s)
  end

  def access_read_and_write
    target.class.attribute_names.include?(@model.name.to_s) || target.class._reflections.keys.include?(@model.name.to_s)
  end

  def id
    "form_field_#{@model.id}"
  end

  def nested_form_field?
    false
  end

  def multiple_nested_form?
    false
  end
end
