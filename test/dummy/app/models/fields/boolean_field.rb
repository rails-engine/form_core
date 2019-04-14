# frozen_string_literal: true

module Fields
  class BooleanField < Field
    serialize :validations, Validations::BooleanField
    serialize :options, NonConfigurable

    def stored_type
      :boolean
    end
  end
end
