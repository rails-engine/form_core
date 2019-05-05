# frozen_string_literal: true

module FormCore
  class Coder
    cattr_accessor :strict

    attr_reader :object_class

    def initialize(object_class)
      @object_class = object_class
    end

    def strict?
      Coder.strict
    end

    def dump(_obj)
      raise NotImplementedError
    end

    def load(_src)
      raise NotImplementedError
    end

    private

      def new_or_raise_decoding_error
        if strict?
          raise DecodingDataCorrupted
        else
          object_class.new
        end
      end

      def valid_attribute_names
        object_class.attribute_names + object_class._embeds_reflections.keys
      end

      def valid_attributes(hash)
        hash.slice(*valid_attribute_names)
      end
  end
end
