# frozen_string_literal: true

require_dependency "concerns/enum_attribute_localizable"

class VirtualModel < FormCore::VirtualModel
  include FormCore::ActiveStorageBridge::Attached::Macros
  include FormCore::ActsAsDefaultValue

  include EnumAttributeLocalizable

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
  end
end
