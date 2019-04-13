# frozen_string_literal: true

module Fields::Options
  class DateField < FieldOptions
    attribute :begin_from, :string, default: "unlimited"
    enum begin_from: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_before_end: "days_before_end"
    }, _prefix: :begin_from

    attribute :begin, :date
    attribute :begin_from_today_days_offset, :integer, default: 0
    attribute :days_before_end, :integer, default: 1

    attribute :end_to, :string, default: "unlimited"
    enum end_to: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_since_begin: "days_since_begin"
    }, _prefix: :end_to

    attribute :end, :date
    attribute :end_to_today_days_offset, :integer, default: 0
    attribute :days_since_begin, :integer, default: 1

    validates :begin_from, :end_to,
              presence: true

    validates :begin,
              presence: true,
              if: :begin_from_date?

    validates :end,
              presence: true,
              if: :end_to_date?

    validates :days_before_end,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :begin_from_days_before_end?

    validates :days_since_begin,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :end_to_days_since_begin?

    validates :begin_from_today_days_offset, :end_to_today_days_offset,
              presence: true,
              numericality: {
                only_integer: true
              }

    validates :begin,
              timeliness: {
                before: ->(r) { Time.zone.today + r.end_to_today_days_offset.days },
                type: :date
              },
              allow_blank: false,
              if: %i[begin_from_date? end_to_today?]

    validates :end,
              timeliness: {
                after: -> { Time.zone.today + r.begin_from_today_days_offset.days },
                type: :date
              },
              allow_blank: false,
              if: %i[begin_from_today? end_to_date?]

    validates :end,
              timeliness: {
                after: :begin,
                type: :date
              },
              allow_blank: false,
              if: %i[begin_from_date? end_to_date?]

    validates :end_to,
              exclusion: {in: %w[today]},
              if: [:begin_from_today?]

    validates :end_to,
              exclusion: {in: %w[days_since_begin]},
              if: [:begin_from_days_before_end?]

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      timeliness = {type: :date}

      if begin_from_today?
        begin_days_offset = begin_from_today_days_offset.days
        timeliness[:on_or_after] = -> { Time.zone.today + begin_days_offset }
      elsif begin_from_date?
        timeliness[:on_or_after] = self.begin
      elsif begin_from_days_before_end?
        days_before_end = self.days_before_end.days
        if end_to_today?
          end_days_offset = end_to_today_days_offset.days
          timeliness[:on_or_after] = -> {
            Time.zone.today + end_days_offset - days_before_end
          }
        elsif end_to_date?
          timeliness[:on_or_after] = self.end - days_before_end
        end
      end

      if end_to_today?
        end_days_offset = end_to_today_date_offset.days
        timeliness[:on_or_before] = -> { Time.zone.today + end_days_offset }
      elsif end_to_date?
        timeliness[:on_or_before] = self.end
      elsif end_to_days_since_begin?
        days_since_begin = self.days_since_begin.days
        if begin_from_today?
          begin_days_offset = begin_from_today_days_offset.days
          timeliness[:on_or_before] = -> {
            Time.zone.today + begin_days_offset + days_since_begin
          }
        elsif begin_from_date?
          timeliness[:on_or_before] = self.begin + days_since_begin
        end
      end

      model.validates field_name,
                      timeliness: timeliness,
                      allow_blank: true
    end
  end
end
