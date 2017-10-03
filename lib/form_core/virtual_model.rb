require "duck_record"

module FormCore
  class VirtualModel < ::DuckRecord::Base
    # Returns the contents of the record as a nicely formatted string.
    def inspect
      # We check defined?(@attributes) not to issue warnings if the object is
      # allocated but not initialized.
      inspection =
        if defined?(@attributes) && @attributes
          self.class.attribute_names.collect do |name|
            if has_attribute?(name)
              "#{name}: #{attribute_for_inspect(name)}"
            end
          end.compact.join(", ")
        else
          "not initialized"
        end

      "#<VirtualModel:#{self.class.name}:#{object_id} #{inspection}>"
    end

    def dump
      self.class.dump(self)
    end

    public_class_method :define_method
    class << self
      def name
        @_name ||= "Form"
      end

      def name=(value)
        value = value.classify
        raise ArgumentError, "`value` isn't a valid class name" if value.blank?

        @_name = value
      end

      def coder
        @_coder ||= FormCore.virtual_model_coder_class.new(self)
      end

      def coder=(klass)
        unless klass && klass < Coder
          raise ArgumentError, "#{klass} should be sub-class of #{Coder}."
        end

        @_coder = klass.new(self)
      end

      delegate :dump, :load, to: :coder, allow_nil: false

      def build(name = nil)
        klass = Class.new(self)
        klass.name = name
        klass
      end

      # Returns a string like "Post(id:integer, title:string, body:text)"
      def inspect
        attr_list = attribute_types.map { |name, type| "#{name}: #{type.type}" } * ", "
        "#<VirtualModel:#{name}:#{object_id} #{attr_list}>"
      end
    end
  end
end
