# frozen_string_literal: true

module Fields::Options
  class TextField < FieldOptions
    attribute :multiline, :boolean, default: false
  end
end
