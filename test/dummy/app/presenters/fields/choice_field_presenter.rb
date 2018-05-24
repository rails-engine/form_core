# frozen_string_literal: true

module Fields
  class ChoiceFieldPresenter < FieldPresenter
    def value_for_preview
      id = value
      return unless id.present?

      if choices.loaded?
        choices.target.find { |choice| choice.id == id }&.label
      else
        choices.find_by(id: id)&.label
      end
    end
  end
end
