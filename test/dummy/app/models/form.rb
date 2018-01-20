# frozen_string_literal: true

class Form < FormCore::Form
  has_many :sections, -> { order(position: :asc) }, dependent: :destroy

  validates :title,
            presence: true

  after_create :auto_create_default_section

  private

  def auto_create_default_section
    sections.create! title: I18n.t("default.section.title"), headless: true
  end
end
