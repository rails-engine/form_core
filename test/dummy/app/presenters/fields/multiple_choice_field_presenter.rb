# frozen_string_literal: true

module Fields
  class MultipleChoiceFieldPresenter < FieldPresenter
    def value_for_preview
      ids = value
      return unless ids.present?

      if choices.loaded?
        choices.target.select { |choice| ids.include?(choice.id) }.map(&:label)
      else
        choices.where(id: ids).map(&:label)
      end.join(", ")
    end
  end
end
