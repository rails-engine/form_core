# frozen_string_literal: true

module Fields
  module Validations::Presence
    extend ActiveSupport::Concern

    included do
      attribute :presence, :boolean, default: false
    end

    def interpret_to(model, field_name, _accessibility, _options = {})
      super
      return unless presence

      model.validates field_name, presence: true
    end
  end
end
