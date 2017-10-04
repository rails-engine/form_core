# frozen_string_literal: true

module Concerns::Fields
  module Options::DataSource
    extend ActiveSupport::Concern

    included do
      # There are something complicated, let's hack it!
      attribute_names_for_nesting << :data_source

      attribute :data_source_type, :string, default: DataSources::Empty.to_s

      def data_source_type=(value)
        unless data_source_type == value
          nested_attributes[:data_source] = data_source.to_h
        end

        super
      end

      validates :data_source_type,
                inclusion: {in: ->(_) { DataSource.descendants.map(&:to_s) }},
                allow_blank: true
    end

    def data_source_class
      data_source_type.safe_constantize || DataSources::Empty
    end

    def data_source
      if attributes[:data_source].class != data_source_class
        nested_attributes[:data_source] = data_source_class.new(nested_attributes[:data_source].to_h)
      end
      nested_attributes[:data_source]
    end

    def data_source=(value)
      if value.respond_to?(:to_h)
        nested_attributes[:data_source] = data_source_class.new(value.to_h)
      elsif value.is_a? data_source_class
        nested_attributes[:data_source] = value
      elsif value.nil?
        nested_attributes[:data_source] = data_source_class.new
      else
        raise ArgumentError,
              "`value` should respond to `to_h` or #{data_source_class}, but got #{value.class}"
      end
    end
  end
end
