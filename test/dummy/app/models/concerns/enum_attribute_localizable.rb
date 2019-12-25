# frozen_string_literal: true

module EnumAttributeLocalizable
  extend ActiveSupport::Concern

  module ClassMethods
    def human_enum_value(attribute, value, options = {})
      parts     = attribute.to_s.split(".")
      attribute = parts.pop.pluralize
      attributes_scope = "#{i18n_scope}.attributes"

      if parts.any?
        namespace = parts.join("/")
        defaults = lookup_ancestors.map do |klass|
          :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.#{attribute}.#{value}"
        end
        defaults << :"#{attributes_scope}.#{namespace}.#{attribute}.#{value}"
      else
        defaults = lookup_ancestors.map do |klass|
          :"#{attributes_scope}.#{klass.model_name.i18n_key}.#{attribute}.#{value}"
        end
      end

      defaults << :"attributes.#{attribute}.#{value}"
      defaults << options.delete(:default) if options[:default]
      defaults << value.to_s.humanize

      options[:default] = defaults
      I18n.translate(defaults.shift, **options)
    end
  end
end
