module FormCore
  class << self
    def data_source_classes
      @data_source_classes ||= Set.new
    end

    def register_data_source_class(klass)
      unless klass && klass < DataSource
        raise ArgumentError, "#{klass} should be sub-class of #{DataSource}."
      end

      data_source_classes << klass
    end

    def register_data_source_classes(*classes)
      classes.each do |klass|
        register_data_source_class klass
      end
    end
  end
end
