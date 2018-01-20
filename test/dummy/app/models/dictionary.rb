# frozen_string_literal: true

class Dictionary < ApplicationRecord
  SCOPE_REGEX = /\A[a-z0-9_.]+\z/

  attribute :value, :string
  validates :value,
            presence: true, uniqueness: {scope: :scope}

  validates :scope,
            presence: true,
            format: {with: SCOPE_REGEX}
end
