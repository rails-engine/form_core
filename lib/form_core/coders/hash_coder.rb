require "yaml"

module FormCore
  class HashCoder < FormCore::Coder # :nodoc:
    def dump(obj)
      obj&.to_h || {}
    end

    def load(hash)
      if hash.nil? || !hash.respond_to?(:to_h)
        return new_or_raise_decoding_error
      end

      object_class.new hash.to_h
    end
  end
end
