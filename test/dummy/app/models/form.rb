# frozen_string_literal: true

class Form < FormCore::Form
  validates :title,
            presence: true

  has_many :sections, dependent: :destroy
end
