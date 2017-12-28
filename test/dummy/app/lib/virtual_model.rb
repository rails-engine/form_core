# frozen_string_literal: true

class VirtualModel < FormCore::VirtualModel
  class << self
    def nested_models
      @nested_models ||= {}
    end

    def attr_readonly?(attr_name)
      readonly_attributes.include? attr_name.to_s
    end
  end
end
