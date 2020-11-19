# frozen_string_literal: true

class MetalForm < ApplicationRecord
  include FormCore::Concerns::Models::Form

  self.table_name = "forms"

  has_many :fields, foreign_key: "form_id", dependent: :destroy

  include Forms::Fake
end
