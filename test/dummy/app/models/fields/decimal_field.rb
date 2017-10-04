# frozen_string_literal: true

module Fields
  class DecimalField < Field
    serialize :validations, Validations::DecimalField
    serialize :options, Options::DecimalField

    def stored_type
      :decimal
    end
  end
end
