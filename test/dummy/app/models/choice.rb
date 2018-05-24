# frozen_string_literal: true

class Choice < ApplicationRecord
  belongs_to :field

  has_many :entry_items, dependent: :delete_all

  validates :label,
            presence: true

  acts_as_list scope: [:field_id]

  def destroyable?
    entry_items.empty?
  end
end
