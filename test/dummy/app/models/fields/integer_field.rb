# frozen_string_literal: true

module Fields
  class IntegerField < Field
    serialize :validations, Validations::IntegerField
    serialize :options, Options::IntegerField

    def stored_type
      :integer
    end

    protected

      def interpret_extra_to(model, accessibility, _overrides = {})
        return if accessibility != :read_and_write

        model.validates name, numericality: { only_integer: true }, allow_blank: true
      end
  end
end
