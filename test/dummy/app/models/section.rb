# frozen_string_literal: true

class Section < ApplicationRecord
  belongs_to :form, touch: true

  has_many :fields, -> { order(position: :asc) }, dependent: :nullify

  acts_as_list scope: [:form_id]

  validates :title,
            presence: true
end
