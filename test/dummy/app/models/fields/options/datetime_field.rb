# frozen_string_literal: true

module Fields::Options
  class DatetimeField < FieldOptions
    attribute :begin_from, :string, default: "unlimited"
    enum begin_from: {
      unlimited: "unlimited",
      now: "now",
      time: "time",
      minutes_before_end: "minutes_before_end"
    }, _prefix: :begin_from

    attribute :begin, :datetime
    attribute :begin_from_now_minutes_offset, :integer, default: 0
    attribute :minutes_before_end, :integer, default: 1

    attribute :end_to, :string, default: "unlimited"
    enum end_to: {
      unlimited: "unlimited",
      now: "now",
      time: "time",
      minutes_since_begin: "minutes_since_begin"
    }, _prefix: :end_to

    attribute :end, :datetime
    attribute :end_to_now_minutes_offset, :integer, default: 0
    attribute :minutes_since_begin, :integer, default: 1

    validates :begin_from, :end_to,
              presence: true

    validates :begin,
              presence: true,
              if: :begin_from_time?

    validates :end,
              presence: true,
              if: :end_to_time?

    validates :minutes_before_end,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :begin_from_minutes_before_end?

    validates :minutes_since_begin,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :end_to_minutes_since_begin?

    validates :begin_from_now_minutes_offset, :end_to_now_minutes_offset,
              presence: true,
              numericality: {
                only_integer: true
              }

    validates :begin,
              timeliness: {
                before: ->(r) { Time.zone.now.change(sec: 0, usec: 0) + r.end_to_now_minutes_offset.minutes },
                type: :datetime
              },
              allow_blank: false,
              if: %i[begin_from_time? end_to_now?]

    validates :end,
              timeliness: {
                after: -> { Time.zone.now.change(sec: 0, usec: 0) + r.begin_from_now_minutes_offset.minutes },
                type: :datetime
              },
              allow_blank: false,
              if: %i[begin_from_now? end_to_time?]

    validates :end,
              timeliness: {
                after: :begin,
                type: :datetime
              },
              allow_blank: false,
              if: %i[begin_from_time? end_to_time?]

    validates :end_to,
              exclusion: {in: %w[now]},
              if: [:begin_from_now?]

    validates :end_to,
              exclusion: {in: %w[minutes_since_begin]},
              if: [:begin_from_minutes_before_end?]

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      timeliness = {type: :datetime}

      if begin_from_now?
        begin_minutes_offset = begin_from_now_minutes_offset.minutes.to_i
        timeliness[:on_or_after] = -> { Time.zone.now.change(sec: 0, usec: 0) + begin_minutes_offset }
      elsif begin_from_time?
        timeliness[:on_or_after] = self.begin
      elsif begin_from_minutes_before_end?
        minutes_before_end = self.minutes_before_end.minutes
        if end_to_now?
          end_minutes_offset = end_to_now_minutes_offset.minutes.to_i
          timeliness[:on_or_after] = -> {
            Time.zone.now.change(sec: 0, usec: 0) + end_minutes_offset - minutes_before_end
          }
        elsif end_to_time?
          timeliness[:on_or_after] = self.end - minutes_before_end
        end
      end

      if end_to_now?
        end_minutes_offset = end_to_now_minutes_offset.minutes.to_i
        timeliness[:on_or_before] = -> { Time.zone.now.change(sec: 0, usec: 0) + end_minutes_offset }
      elsif end_to_time?
        timeliness[:on_or_before] = self.end
      elsif end_to_minutes_since_begin?
        minutes_since_begin = self.minutes_since_begin.minutes.to_i
        if begin_from_now?
          begin_minutes_offset = begin_from_now_minutes_offset.minutes.to_i
          timeliness[:on_or_before] = -> {
            Time.zone.now.change(sec: 0, usec: 0) + begin_minutes_offset + minutes_since_begin
          }
        elsif begin_from_time?
          timeliness[:on_or_before] = self.begin + minutes_since_begin
        end
      end

      model.validates field_name,
                      timeliness: timeliness,
                      allow_blank: true
    end
  end
end
