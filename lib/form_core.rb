require "form_core/engine"
require "form_core/virtual_model"

require "form_core/concerns/models/form"
require "form_core/concerns/models/field"

module FormCore
  class << self
    def field_classes
      @field_classes ||= Set.new
    end

    def register_field_class(klass)
      unless klass && klass < Field && !klass.abstract_class?
        raise ArgumentError, "#{klass} should be sub-class of #{Field} and can't be abstract class."
      end

      field_classes << klass
    end

    def register_field_classes(*classes)
      classes.each do |klass|
        register_field_class klass
      end
    end

    def virtual_model_class
      @virtual_model_class ||= VirtualModel
    end

    def virtual_model_class=(klass)
      unless klass && klass < VirtualModel
        raise ArgumentError, "#{klass} should be sub-class of #{VirtualModel}."
      end

      @virtual_model_class = klass
    end

    def reserved_names
      @reserved_names ||= Set.new(
        %i(def class module private public protected allocate new parent superclass) +
          virtual_model_class.instance_methods(true)
      )
    end
  end
end
