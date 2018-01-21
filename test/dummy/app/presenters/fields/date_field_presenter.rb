# frozen_string_literal: true

module Fields
  class DateFieldPresenter < FieldPresenter
    def value_for_preview
      value = super
      I18n.l(value) if value
    end
  end
end
