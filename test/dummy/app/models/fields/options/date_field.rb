# frozen_string_literal: true

module Fields::Options
  class DateField < FieldOptions
    attribute :start_from, :string, default: "unlimited"
    enum start_from: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_before_finish: "days_before_finish"
    }, _prefix: :start_from

    attribute :start, :date
    attribute :start_from_today_days_offset, :integer, default: 0
    attribute :days_before_finish, :integer, default: 1

    attribute :finish_to, :string, default: "unlimited"
    enum finish_to: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_since_start: "days_since_start"
    }, _prefix: :finish_to

    attribute :finish, :date
    attribute :finish_to_today_days_offset, :integer, default: 0
    attribute :days_since_start, :integer, default: 1

    validates :start_from, :finish_to,
              presence: true

    validates :start,
              presence: true,
              if: :start_from_date?

    validates :finish,
              presence: true,
              if: :finish_to_date?

    validates :days_before_finish,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :start_from_days_before_finish?

    validates :days_since_start,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :finish_to_days_since_start?

    validates :start_from_today_days_offset, :finish_to_today_days_offset,
              presence: true,
              numericality: {
                only_integer: true
              }

    validates :start,
              timeliness: {
                before: ->(r) { Time.zone.today + r.finish_to_today_days_offset.days },
                type: :date
              },
              allow_blank: false,
              if: %i[start_from_date? finish_to_today?]

    validates :finish,
              timeliness: {
                after: -> { Time.zone.today + r.start_from_today_days_offset.days },
                type: :date
              },
              allow_blank: false,
              if: %i[start_from_today? finish_to_date?]

    validates :finish,
              timeliness: {
                after: :start,
                type: :date
              },
              allow_blank: false,
              if: %i[start_from_date? finish_to_date?]

    validates :finish_to,
              exclusion: {in: %w[today]},
              if: [:start_from_today?]

    validates :finish_to,
              exclusion: {in: %w[days_since_start]},
              if: [:start_from_days_before_finish?]

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      timeliness = {type: :date}

      if start_from_today?
        start_days_offset = start_from_today_days_offset.days
        timeliness[:on_or_after] = -> { Time.zone.today + start_days_offset }
      elsif start_from_date?
        timeliness[:on_or_after] = start
      elsif start_from_days_before_finish?
        days_before_finish = self.days_before_finish.days
        if finish_to_today?
          finish_days_offset = finish_to_today_days_offset.days
          timeliness[:on_or_after] = -> {
            Time.zone.today + finish_days_offset - days_before_finish
          }
        elsif finish_to_date?
          timeliness[:on_or_after] = finish - days_before_finish
        end
      end

      if finish_to_today?
        finish_days_offset = finish_to_today_date_offset.days
        timeliness[:on_or_before] = -> { Time.zone.today + finish_days_offset }
      elsif finish_to_date?
        timeliness[:on_or_before] = finish
      elsif finish_to_days_since_start?
        days_since_start = self.days_since_start.days
        if start_from_today?
          start_days_offset = start_from_today_days_offset.days
          timeliness[:on_or_before] = -> {
            Time.zone.today + start_days_offset + days_since_start
          }
        elsif start_from_date?
          timeliness[:on_or_before] = start + days_since_start
        end
      end

      model.validates field_name,
                      timeliness: timeliness,
                      allow_blank: true
    end
  end
end
