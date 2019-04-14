# frozen_string_literal: true

module Fields
  module Embeds
    class IntegerRange < VirtualModel
      attribute :begin, :integer
      attribute :end, :integer

      validates :begin, :end,
                presence: true,
                numericality: {only_integer: true}

      validates :end,
                numericality: {
                  greater_than: :begin
                },
                allow_blank: true,
                if: -> { read_attribute(:begin).present? }
    end
  end
end
