module Concerns::Fields
  module Options::DataSource
    extend ActiveSupport::Concern

    included do
      attribute_names << :data_source

      attribute :data_source_type, :string, default: DataSources::Empty.to_s

      def data_source_type=(value)
        unless data_source_type == value
          attributes[:data_source] = @_data_source.to_h_with_unused
          @_data_source = nil
        end

        super
      end

      validates :data_source_type,
                inclusion: {in: -> (_) { FormCore.data_source_classes.map(&:to_s) }},
                allow_blank: true
    end

    def data_source_class
      data_source_type.safe_constantize || DataSources::Empty
    end

    def data_source
      @_data_source ||= data_source_class.new(attributes[:data_source])
    end

    def data_source=(value)
      if value.respond_to?(:to_h)
        @_data_source = data_source_class.new(value.to_h)
      elsif value.is_a? data_source_class
        @_data_source = value
      elsif value.nil?
        @_data_source = data_source_class.new
      else
        raise ArgumentError,
              "`value` should respond to `to_h` or #{data_source_class}, but got #{value.class}"
      end
    end
  end
end
