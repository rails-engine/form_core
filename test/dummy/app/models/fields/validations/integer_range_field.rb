# frozen_string_literal: true

module Fields::Validations
  class IntegerRangeField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
