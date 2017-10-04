# frozen_string_literal: true

module ApplicationHelper
  def options_for_enum_select(klass, attribute, selected = nil)
    container = klass.public_send(attribute.to_s.pluralize).map do |k, v|
      v ||= k
      [klass.human_enum_value(attribute, k), v]
    end

    options_for_select(container, selected)
  end

  def present(model, options = {})
    klass = options.delete(:presenter_class) || "#{model.class}Presenter".constantize
    presenter = klass.new(model, self, options)

    yield(presenter) if block_given?

    presenter
  end
end
