module Concerns::OptionsModel
  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods
      def attribute(name, cast_type, default: nil, array: false)
        name = name.to_sym
        if dangerous_attribute_method?(name)
          raise ArgumentError, "#{name} is defined by #{self.class}. Check to make sure that you don't have an attribute or method with the same name."
        end

        ActiveModel::Type.lookup(cast_type)

        attribute_defaults[name] = default

        generated_attribute_methods.synchronize do
          generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
          def #{name}
            value = attributes[:#{name}]
            return value unless value.nil?
            attributes[:#{name}] = self.class.attribute_defaults[:#{name}].#{default.respond_to?(:call) ? "call" : "dup"}
            attributes[:#{name}]
          end
          STR

          if array
            generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{name}=(value)
              if value.respond_to?(:to_a)
                attributes[:#{name}] = value.to_a.map { |i| ActiveModel::Type.lookup(:#{cast_type}).cast(i) }
              elsif value.nil?
                attributes[:#{name}] = self.class.attribute_defaults[:#{name}].#{default.respond_to?(:call) ? "call" : "dup"}
              else
                raise ArgumentError,
                      "`value` should respond to `to_a`, but got \#{value.class} -- \#{value.inspect}"
              end
            end
            STR
          else
            generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{name}=(value)
              attributes[:#{name}] = ActiveModel::Type.lookup(:#{cast_type}).cast(value)
            end
            STR

            if cast_type == :boolean
              generated_attribute_methods.send :alias_method, :"#{name}?", name
            end
          end
        end

        self.attribute_names << name
        name
      end

      def enum_attribute(name, enum, default: nil, allow_nil: false)
        unless enum.is_a?(Array) && enum.any?
          raise ArgumentError, "enum should be an Array and can't empty"
        end
        enum = enum.map(&:to_s)

        attribute name, :string, default: default

        pluralized_name = name.to_s.pluralize
        generated_class_methods.synchronize do
          generated_class_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
          def #{pluralized_name}
            @_#{pluralized_name} ||= %w(#{enum.join(" ")}).freeze
          end
          STR

          validates name, inclusion: {in: enum}, allow_nil: allow_nil
        end
      end

      def has_one(name, class_name: nil, anonymous_class: nil)
        if class_name.blank? && anonymous_class.nil?
          raise ArgumentError, "must provide at least one of `class_name` or `anonymous_class`"
        end

        name = name.to_sym
        if dangerous_attribute_method?(name)
          raise ArgumentError, "#{name} is defined by #{self.class}. Check to make sure that you don't have an attribute or method with the same name."
        end

        if class_name.present?
          nested_classes[name] = class_name.constantize
        else
          nested_classes[name] = anonymous_class
        end

        generated_attribute_methods.synchronize do
          generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
          def #{name}
            @_#{name} ||= self.class.nested_classes[:#{name}].new(attributes[:#{name}])
          end
          STR

          generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
          def #{name}=(value)
            klass = self.class.nested_classes[:#{name}]
            if value.respond_to?(:to_h)
              @_#{name} = klass.new(value.to_h)
            elsif value.is_a? klass
              @_#{name} = value
            elsif value.nil?
              @_#{name} = klass.new
            else
              raise ArgumentError,
                    "`value` should respond to `to_h` or \#{klass}, but got \#{value.class}"
            end
          end
          STR
        end

        self.attribute_names << name
        name
      end

      def attribute_defaults
        @attribute_defaults ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def nested_classes
        @nested_classes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def attribute_names
        @attribute_names ||= Set.new
      end

      protected

      # A method name is 'dangerous' if it is already (re)defined by OptionsModel, but
      # not by any ancestors. (So 'puts' is not dangerous but 'save' is.)
      def dangerous_attribute_method?(name) # :nodoc:
        method_defined_within?(name, self.class)
      end

      def method_defined_within?(name, klass, superklass = klass.superclass) # :nodoc:
        if klass.method_defined?(name) || klass.private_method_defined?(name)
          if superklass.method_defined?(name) || superklass.private_method_defined?(name)
            klass.instance_method(name).owner != superklass.instance_method(name).owner
          else
            true
          end
        else
          false
        end
      end

      def generated_attribute_methods
        @generated_attribute_methods ||= Module.new {
          extend Mutex_m
        }.tap { |mod| include mod }
      end

      def generated_class_methods
        @generated_class_methods ||= Module.new {
          extend Mutex_m
        }.tap { |mod| extend mod }
      end
    end
  end
end
