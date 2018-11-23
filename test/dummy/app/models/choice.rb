# frozen_string_literal: true

class Choice < ApplicationRecord
  belongs_to :field

  validates :label,
            presence: true

  acts_as_list scope: [:field_id]
end
