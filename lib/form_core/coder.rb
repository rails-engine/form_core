module FormCore
  class Coder
    attr_reader :object_class

    def initialize(object_class, strict: false)
      @object_class = object_class
      @strict = strict
    end

    def strict?
      @strict
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
  end
end
