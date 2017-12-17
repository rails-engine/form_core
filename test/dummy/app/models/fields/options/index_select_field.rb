# frozen_string_literal: true

module Fields::Options
  class IndexSelectField < FieldOptions
    attribute :collection, :string, default: [], array_without_blank: true
  end
end
