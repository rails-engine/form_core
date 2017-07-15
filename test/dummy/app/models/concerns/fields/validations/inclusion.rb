module Concerns::Fields
  module Validations::Inclusion
    extend ActiveSupport::Concern

    included do
      embeds_one :inclusion, anonymous_class: InclusionOptions
    end

    def interpret_to(model, field_name, accessibility, options = {})
      super
      inclusion.interpret_to model, field_name, accessibility, options
    end

    class InclusionOptions < FieldOptions
      attribute :message, :string, default: ""
      attribute :in, :string, default: [], array: true

      def interpret_to(model, field_name, _accessibility, _options = {})
        return if self.in.empty?

        options = {in: self.in}
        options[:message] = message if message.present?

        model.validates field_name, inclusion: options, allow_blank: true
      end
    end
  end
end
