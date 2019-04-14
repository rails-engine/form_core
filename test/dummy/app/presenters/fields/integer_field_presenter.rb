# frozen_string_literal: true

module Fields
  class IntegerFieldPresenter < FieldPresenter
    include Fields::PresenterForNumberField

    def integer_only?
      true
    end
  end
end
