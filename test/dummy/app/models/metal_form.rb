# frozen_string_literal: true

class MetalForm < ApplicationRecord
  include FormCore::Concerns::Models::Form

  self.table_name = "forms"

  has_many :fields, foreign_key: "form_id"

  default_value_for :name,
                    ->(_) { "form_#{SecureRandom.hex(3)}" },
                    allow_nil: false

  include Forms::Fake
end
