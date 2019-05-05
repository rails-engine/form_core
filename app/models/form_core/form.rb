# frozen_string_literal: true

module FormCore
  class Form < ApplicationRecord
    include FormCore::Concerns::Models::Form

    self.table_name = "forms"

    has_many :fields, dependent: :destroy
  end
end
