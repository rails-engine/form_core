module Concerns::OptionsModel
  module AttributeAssignment
    extend ActiveSupport::Concern

    def initialize(attributes = {})
      update(attributes)
    end

    def initialize_dup(other)
      super

      update(other)
    end

    def update(other)
      return unless other

      unless other.respond_to?(:to_h)
        raise ArgumentError, "#{other} must be respond to `to_h`"
      end

      other.to_h.each do |k, v|
        if respond_to?("#{k}=")
          public_send("#{k}=", v)
        else
          unused_attributes[k] = v
        end
      end
    end

    def [](key)
      public_send(key) if respond_to?(key)
    end

    def []=(key, val)
      setter = "#{key}="
      if respond_to?(setter)
        public_send(setter, val)
      else
        unused_attributes[key] = val
      end
    end

    def fetch(key, default = nil)
      if self.class.attribute_names.exclude?(key.to_sym) && default.nil? && !block_given?
        raise KeyError, "attribute not found"
      end

      value = respond_to?(key) ? public_send(key) : nil
      return value if value

      if default
        default
      elsif block_given?
        yield
      end
    end

    def _attributes
      @attributes ||= ActiveSupport::HashWithIndifferentAccess.new
    end
    private :_attributes
    alias_method :attributes, :_attributes

    def _unused_attributes
      @unused_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
    end
    private :_unused_attributes
    alias_method :unused_attributes, :_unused_attributes
  end
end
