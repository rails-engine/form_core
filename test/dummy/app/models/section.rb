class Section < ApplicationRecord
  belongs_to :form, touch: true

  has_many :fields, dependent: :nullify
end
