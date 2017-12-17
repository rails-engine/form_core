# frozen_string_literal: true

class Form < FormCore::Form
  has_many :sections, dependent: :destroy

  validates :title,
            presence: true
end
