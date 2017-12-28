# frozen_string_literal: true

module FormCore::Concerns
  module Models
    module Field
      extend ActiveSupport::Concern

      included do
        enum accessibility: {read_and_write: 0, readonly: 1, hidden: 2},
             _prefix: :access

        serialize :validations
        serialize :options

        validates :name,
                  presence: true,
                  uniqueness: {scope: :form},
                  exclusion: {in: FormCore.reserved_names},
                  format: {with: /\A[a-z0-9_]+\z/}
        validates :accessibility,
                  inclusion: {in: self.accessibilities.keys.map(&:to_sym)}

        after_initialize do
          self.validations ||= {}
          self.options ||= {}
          self.accessibility ||= "read_and_write"
        end
      end

      def name
        self[:name]&.to_sym
      end

      def accessibility
        self[:accessibility]&.to_sym
      end

      def stored_type
        raise NotImplementedError
      end

      def default_value
        nil
      end

      def interpret_to(model, overrides: {})
        check_model_validity!(model)

        accessibility = overrides.fetch(:accessibility, self.accessibility)
        return model if accessibility == :hidden

        default_value = overrides.fetch(:default_value, self.default_value)
        model.attribute name, stored_type, default: default_value

        if accessibility == :readonly
          model.attr_readonly name
        end

        interpret_validations_to model, accessibility, overrides
        interpret_extra_to model, accessibility, overrides

        model
      end

      protected

      def interpret_validations_to(model, accessibility, overrides = {})
        validations = overrides.fetch(:validations, (self.validations || {}))
        validation_options = overrides.fetch(:validation_options) { self.options.fetch(:validation, {}) }

        if accessibility == :read_and_write && validations.present?
          model.validates name, **validations, **validation_options
        end
      end

      def interpret_extra_to(_model, _accessibility, _overrides = {})
      end

      def check_model_validity!(model)
        unless model.is_a?(Class) && model < ::FormCore::VirtualModel
          raise ArgumentError, "#{model} must be a #{::FormCore::VirtualModel}'s subclass"
        end
      end
    end
  end
end
