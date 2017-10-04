# frozen_string_literal: true

module FormCore::Concerns
  module Models
    module Form
      extend ActiveSupport::Concern

      included do
        has_many :fields
      end

      def to_virtual_model(model_name: "Form",
                           fields_scope: proc { |fields| fields },
                           overrides: {})
        model = FormCore.virtual_model_class.build model_name

        append_to_virtual_model(model, fields_scope: fields_scope, overrides: overrides)
      end

      def append_to_virtual_model(model,
                                  fields_scope: proc { |fields| fields },
                                  overrides: {})
        check_model_validity! model

        fields_scope.call(fields).each do |f|
          f.interpret_to model, overrides: overrides.fetch(f.name, {})
        end

        model
      end

      private

      def check_model_validity!(model)
        unless model.is_a?(Class) && model < ::FormCore::VirtualModel
          raise ArgumentError, "#{model} must be a #{::FormCore::VirtualModel}'s subclass"
        end
      end
    end
  end
end
