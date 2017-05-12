module Concerns::OptionsModel
  module Serialization
    extend ActiveSupport::Concern

    def to_h
      hash = {}

      self.class.attribute_names.each do |attribute_name|
        attribute = public_send(attribute_name)
        if attribute.is_a?(OptionsModel)
          hash[attribute_name] = attribute.to_h
        else
          hash[attribute_name] = attribute
        end
      end

      hash
    end

    def to_h_with_unused
      to_h.merge unused_attributes
    end

    module ClassMethods
      def dump(obj)
        return YAML.dump({}) unless obj

        unless obj.is_a? OptionsModel
          raise SerializationTypeMismatch,
                "can't dump: was supposed to be a #{OptionsModel}, but was a #{obj.class}. -- #{obj.inspect}"
        end

        YAML.dump obj.to_h
      end

      def load(yaml)
        return new unless yaml
        return new unless yaml.is_a?(String) && /^---/.match?(yaml)

        hash = YAML.load(yaml) || Hash.new

        unless hash.is_a? Hash
          raise SerializationTypeMismatch,
                "can't load: was supposed to be a #{Hash}, but was a #{hash.class}. -- #{hash.inspect}"
        end

        new hash
      end
    end
  end
end
