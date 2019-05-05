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

      return new_or_raise_decoding_error unless yaml.is_a?(String) && /^---/.match?(yaml)

      decoded =
        if safe_mode?
          YAML.safe_load(yaml, YAMLCoder.whitelist_classes)
        else
          YAML.safe_load(yaml)
        end
      return new_or_raise_decoding_error unless decoded.is_a? Hash

      object_class.new valid_attributes(decoded)
    end
  end
end
