# frozen_string_literal: true

module Fields
  class BooleanFieldPresenter < FieldPresenter
    def value_for_preview
      super ? I18n.t("values.true") : I18n.t("values.false")
    end
  end
end
