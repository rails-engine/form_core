require "form_core/engine"
require "form_core/errors"

require "form_core/coder"
require "form_core/coders/hash_coder"
require "form_core/coders/yaml_coder"

require "form_core/virtual_model"
require "form_core/concerns/models/form"
require "form_core/concerns/models/field"

module FormCore
  class << self
    def virtual_model_class
      @virtual_model_class ||= VirtualModel
    end

    def virtual_model_class=(klass)
      unless klass && klass < VirtualModel
        raise ArgumentError, "#{klass} should be sub-class of #{VirtualModel}."
      end

      @reserved_names = nil
      @virtual_model_class = klass
    end

    def reserved_names
      @reserved_names ||= Set.new(
        %i(def class module private public protected allocate new parent superclass) +
          virtual_model_class.instance_methods(true)
      )
    end

    def virtual_model_coder_class
      @virtual_model_coder_class ||= HashCoder
    end

    def virtual_model_coder_class=(klass)
      unless klass && klass < Coder
        raise ArgumentError, "#{klass} should be sub-class of #{Coder}."
      end

      @virtual_model_coder_class = klass
    end
  end
end
