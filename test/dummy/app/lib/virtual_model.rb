# frozen_string_literal: true

class VirtualModel < FormCore::VirtualModel
  class << self
    def nested_models
      @nested_models ||= {}
    end
  end
end
