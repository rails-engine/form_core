# frozen_string_literal: true

module Fields::Validations
  class AttachmentField < FieldOptions
    prepend Concerns::Fields::Validations::Presence
  end
end
