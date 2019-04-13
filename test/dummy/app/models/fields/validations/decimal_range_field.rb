# frozen_string_literal: true

module Fields::Validations
  class DecimalRangeField < FieldOptions
    prepend Fields::Validations::Presence
  end
end
