# frozen_string_literal: true

module Fields
  module Embeds
    class DecimalRange < VirtualModel
      attribute :begin, :decimal
      attribute :end, :decimal

      validates :begin, :end,
                presence: true,
                numericality: { only_integer: false }

      validates :end,
                numericality: {
                  greater_than: :begin
                },
                allow_blank: true,
                if: -> { read_attribute(:begin).present? }
    end
  end
end
