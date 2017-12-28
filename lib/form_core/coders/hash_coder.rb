# frozen_string_literal: true

require "yaml"

module FormCore
  class HashCoder < FormCore::Coder # :nodoc:
    def dump(obj)
      obj&.serializable_hash || {}
    end

    def load(hash)
      if hash.nil? || !hash.respond_to?(:to_h)
        return new_or_raise_decoding_error
      end

      object_class.new valid_attributes(hash)
    end
  end
end
