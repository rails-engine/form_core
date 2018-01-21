# frozen_string_literal: true

module Fields
  class DatetimeFieldPresenter < FieldPresenter
    def value_for_preview
      value = super
      value.to_formatted_s if value
    end
  end
end
