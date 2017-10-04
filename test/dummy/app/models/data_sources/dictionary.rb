# frozen_string_literal: true

module DataSources
  class Dictionary < DataSource
    def text_method
      :value
    end

    attribute :scope, :string, default: ""

    class << self
      def scoped_records(condition)
        return ::Dictionary.none if condition.blank?

        ::Dictionary.where(condition)
      end
    end
  end
end
