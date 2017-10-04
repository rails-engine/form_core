# frozen_string_literal: true

require "yaml"

module FormCore
  class YAMLCoder < FormCore::Coder # :nodoc:
    def dump(obj)
      return YAML.dump({}) unless obj

      YAML.dump obj.to_h
    end

    def load(yaml)
      return object_class.new if yaml.blank?

      unless yaml.is_a?(String) && /^---/.match?(yaml)
        return new_or_raise_decoding_error
      end

      decoded = YAML.load(yaml)
      unless decoded.is_a? Hash
        return new_or_raise_decoding_error
      end

      object_class.new decoded
    end
  end
end
