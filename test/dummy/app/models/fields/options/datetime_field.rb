# frozen_string_literal: true

module Fields::Options
  class DatetimeField < FieldOptions
    attribute :start_from, :string, default: "unlimited"
    enum start_from: {
      unlimited: "unlimited",
      now: "now",
      time: "time",
      minutes_before_finish: "minutes_before_finish"
    }, _prefix: :start_from

    attribute :start_time, :datetime
    attribute :start_from_now_minutes_offset, :integer, default: 0
    attribute :minutes_before_finish, :integer, default: 1

    attribute :finish_to, :string, default: "unlimited"
    enum finish_to: {
      unlimited: "unlimited",
      now: "now",
      time: "time",
      minutes_since_start: "minutes_since_start"
    }, _prefix: :finish_to

    attribute :finish_time, :datetime
    attribute :finish_to_now_minutes_offset, :integer, default: 0
    attribute :minutes_since_start, :integer, default: 1

    validates :start_from, :finish_to,
              presence: true

    validates :start_time,
              presence: true,
              if: :start_from_time?

    validates :finish_time,
              presence: true,
              if: :finish_to_time?

    validates :minutes_before_finish,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :start_from_minutes_before_finish?

    validates :minutes_since_start,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :finish_to_minutes_since_start?

    validates :start_from_now_minutes_offset, :finish_to_now_minutes_offset,
              presence: true,
              numericality: {
                only_integer: true
              }

    validates :start_time,
              timeliness: {
                before: ->(r) { Time.zone.now.change(sec: 0, usec: 0) + r.finish_to_now_minutes_offset.minutes },
                type: :datetime
              },
              allow_blank: false,
              if: [:start_from_time?, :finish_to_now?]

    validates :finish_time,
              timeliness: {
                after: -> { Time.zone.now.change(sec: 0, usec: 0) + r.start_from_now_minutes_offset.minutes },
                type: :datetime
              },
              allow_blank: false,
              if: [:start_from_now?, :finish_to_time?]

    validates :finish_time,
              timeliness: {
                after: :start_time,
                type: :datetime
              },
              allow_blank: false,
              if: [:start_from_time?, :finish_to_time?]

    validates :finish_to,
              exclusion: {in: %w[now]},
              if: [:start_from_now?]

    validates :finish_to,
              exclusion: {in: %w[minutes_since_start]},
              if: [:start_from_minutes_before_finish?]

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      timeliness = {type: :datetime}

      if start_from_now?
        start_time_minutes_offset = self.start_from_now_minutes_offset.minutes.to_i
        timeliness[:on_or_after] = -> { Time.zone.now.change(sec: 0, usec: 0) + start_time_minutes_offset }
      elsif start_from_time?
        timeliness[:on_or_after] = start_time
      elsif start_from_minutes_before_finish?
        minutes_before_finish = self.minutes_before_finish.minutes
        if finish_to_now?
          finish_time_minutes_offset = self.finish_to_now_minutes_offset.minutes.to_i
          timeliness[:on_or_after] = -> {
            Time.zone.now.change(sec: 0, usec: 0) + finish_time_minutes_offset - minutes_before_finish
          }
        elsif finish_to_time?
          timeliness[:on_or_after] = finish_time - minutes_before_finish
        end
      end

      if finish_to_now?
        finish_time_minutes_offset = self.finish_to_now_minutes_offset.minutes.to_i
        timeliness[:on_or_before] = -> { Time.zone.now.change(sec: 0, usec: 0) + finish_time_minutes_offset }
      elsif finish_to_time?
        timeliness[:on_or_before] = finish_time
      elsif finish_to_minutes_since_start?
        minutes_since_start = self.minutes_since_start.minutes.to_i
        if start_from_now?
          start_time_minutes_offset = self.start_from_now_minutes_offset.minutes.to_i
          timeliness[:on_or_before] = -> {
            Time.zone.now.change(sec: 0, usec: 0) + start_time_minutes_offset + minutes_since_start
          }
        elsif start_from_time?
          timeliness[:on_or_before] = start_time + minutes_since_start
        end
      end

      model.validates field_name,
                      timeliness: timeliness,
                      allow_blank: true
    end
  end
end
