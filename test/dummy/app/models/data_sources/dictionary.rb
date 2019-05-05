# frozen_string_literal: true

module DataSources
  class Dictionary < DataSource
    def text_method
      :value
    end

    def value_for_preview_method
      :value
    end

    attribute :scope, :string, default: ""

    validates :scope,
              format: { with: ::Dictionary::SCOPE_REGEX },
              allow_blank: true

    class << self
      def scoped_records(condition)
        return ::Dictionary.none if condition.blank?

        ::Dictionary.where(condition)
      end
    end
  end
end
