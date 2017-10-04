# frozen_string_literal: true

module Fields
  class DecimalFieldPresenter < FieldPresenter
    include Concerns::Fields::PresenterForNumberField
  end
end
