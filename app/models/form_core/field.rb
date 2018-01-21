# frozen_string_literal: true

module FormCore
  class Field < ApplicationRecord
    include FormCore::Concerns::Models::Field

    self.table_name = "fields"

    belongs_to :form, touch: true
  end
end
