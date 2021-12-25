# frozen_string_literal: true

class VirtualModel < FormCore::VirtualModel
  include FormCore::ActiveStorageBridge::Attached::Macros
  include FormCore::ActsAsDefaultValue

  include EnumAttributeLocalizable

  # self.inheritance_column = nil

  def persisted?
    false
  end

  class << self
    def nested_models
      @nested_models ||= {}
    end

    def attr_readonly?(attr_name)
      readonly_attributes.include? attr_name.to_s
    end

    def metadata
      @metadata ||= {}
    end

    def _embeds_reflections
      _reflections.select { |_, v| v.is_a? ActiveEntity::Reflection::EmbeddedAssociationReflection }
    end
  end
end
