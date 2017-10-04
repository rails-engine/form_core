# frozen_string_literal: true

module Fields
  class TextField < Field
    serialize :validations, Validations::TextField
    serialize :options, Options::TextField

    def stored_type
      :string
    end
  end
end
