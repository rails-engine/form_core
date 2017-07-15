module Concerns::Fields
  module Validations::Format
    extend ActiveSupport::Concern

    included do
      embeds_one :format, anonymous_class: FormatOptions
    end

    def interpret_to(model, field_name, accessibility, options = {})
      super
      format.interpret_to model, field_name, accessibility, options
    end

    class FormatOptions < FieldOptions
      attribute :with, :string, default: ""
      attribute :message, :string, default: ""

      validate do
        begin
          Regexp.new(with) if with.present?
        rescue RegexpError
          errors.add :with, :invalid
        end
      end

      def interpret_to(model, field_name, _accessibility, _options = {})
        return if with.blank?

        with = Regexp.new(self.with)

        options = {with: with}
        options[:message] = message if message.present?

        model.validates field_name, format: options, allow_blank: true
      end
    end
  end
end
