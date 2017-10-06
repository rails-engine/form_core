# frozen_string_literal: true

module Fields
  class DateField < Field
    serialize :validations, Validations::DateField
    serialize :options, Options::DateField

    def stored_type
      :date
    end
  end
end
