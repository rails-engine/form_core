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

  def access_readonly?
    target.class.attr_readonly?(@model.name)
  end

  def id
    "form_field_#{@model.id}"
  end
end
