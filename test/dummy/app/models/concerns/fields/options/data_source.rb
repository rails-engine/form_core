# frozen_string_literal: true

module Concerns::Fields
  module Options::DataSource
    extend ActiveSupport::Concern

    included do
      attribute :data_source_type, :string, default: DataSources::Empty.to_s

      ::DataSource.descendants.each do |klass|
        key = :"#{klass.type_key}_data_source"
        has_one key, class_name: klass.to_s
        accepts_nested_attributes_for key
      end

      validates :data_source_type,
                inclusion: {in: ->(_) { ::DataSource.descendants.map(&:to_s) }},
                allow_blank: false
    end

    def data_source
      send(:"#{data_source_class.type_key}_data_source") || send(:"build_#{data_source_class.type_key}_data_source")
    end

    def data_source_class
      data_source_type.safe_constantize || ::DataSources::Empty
    end
  end
end
