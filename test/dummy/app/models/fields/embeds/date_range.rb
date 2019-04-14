# frozen_string_literal: true

module Fields
  module Embeds
    class DateRange < VirtualModel
      attribute :begin, :datetime
      attribute :end, :datetime

      validates :begin,
                presence: true

      validates :end,
                timeliness: {
                  after: :begin,
                  type: :date
                },
                allow_blank: true,
                if: -> { read_attribute(:begin).present? }

      def begin=(val)
        super(val.try(:in_time_zone)&.utc)
      end

      def end=(val)
        super(val.try(:in_time_zone)&.utc)
      end
    end
  end
end
