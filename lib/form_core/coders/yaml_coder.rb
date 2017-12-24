# frozen_string_literal: true

require "yaml"

module FormCore
  class YAMLCoder < FormCore::Coder # :nodoc:
    cattr_accessor :safe_mode

    def self.whitelist_classes
      @whitelist_classes ||= []
    end

    def safe_mode?
      YAMLCoder.safe_mode
    end

    def dump(obj)
      return YAML.dump({}) unless obj

      YAML.dump obj.serializable_hash
    end

    def load(yaml)
      return object_class.new if yaml.blank?

      unless yaml.is_a?(String) && /^---/.match?(yaml)
        return new_or_raise_decoding_error
      end

      decoded =
        if safe_mode?
          YAML.safe_load(yaml, YAMLCoder.whitelist_classes)
        else
          YAML.load(yaml)
        end
      unless decoded.is_a? Hash
        return new_or_raise_decoding_error
      end

      object_class.new decoded
    end
  end
end
