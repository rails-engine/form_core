# frozen_string_literal: true

module Fields
  module Helper
    extend ActiveSupport::Concern

    def options_configurable?
      options.is_a?(FieldOptions) && options.attributes.any?
    end

    def validations_configurable?
      validations.is_a?(FieldOptions) && validations.attributes.any?
    end

    def attached_choices?
      false
    end

    def attached_data_source?
      false
    end

    def attached_nested_form?
      false
    end
  end
end
