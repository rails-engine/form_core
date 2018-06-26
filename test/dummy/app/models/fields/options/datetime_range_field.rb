# frozen_string_literal: true

module Fields::Options
  class DatetimeRangeField < FieldOptions
    attribute :start_from, :string, default: "unlimited"
    enum start_from: {
      unlimited: "unlimited",
      now: "now",
      time: "time",
      minutes_before_finish: "minutes_before_finish"
    }, _prefix: :start_from

    attribute :start_time, :datetime
    attribute :fixed_start_time, :boolean, default: false
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
    attribute :fixed_finish_time, :boolean, default: false
    attribute :finish_to_now_minutes_offset, :integer, default: 0
    attribute :minutes_since_start, :integer, default: 1

    attribute :minimum_distance, :integer, default: 0
    attribute :maximum_distance, :integer, default: 0

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

    validates :fixed_finish_time,
              absence: true,
              if: [:fixed_start_time]

    validates :fixed_start_time,
              absence: true,
              if: [:start_from_minutes_before_finish?]

    validates :fixed_finish_time,
              absence: true,
              if: [:finish_to_minutes_since_start?]

    validates :minimum_distance,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0
              },
              allow_blank: false

    validates :maximum_distance,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: :minimum_distance
              },
              allow_blank: false,
              unless: -> (r) { r.maximum_distance.to_i == 0 }

    def interpret_to(model, field_name, _accessibility, _options = {})
      klass = model.nested_models[field_name]

      start_time_minutes_offset = self.start_from_now_minutes_offset.minutes.to_i
      finish_time_minutes_offset = self.finish_to_now_minutes_offset.minutes.to_i

      if start_from_now?
        klass.validates :start_time,
                        timeliness: {
                          on_or_after: -> { Time.zone.now.change(sec: 0, usec: 0) + start_time_minutes_offset },
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :start_time,
                                -> (_) { Time.zone.now.change(sec: 0, usec: 0) + start_time_minutes_offset },
                                allow_nil: false
        if fixed_start_time
          klass.attr_readonly :start_time
        end
      elsif start_from_time?
        klass.validates :start_time,
                        timeliness: {
                          on_or_after: start_time,
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :start_time,
                                start_time,
                                allow_nil: false
        if fixed_start_time
          klass.attr_readonly :start_time
        end
      elsif start_from_minutes_before_finish?
        minutes_before_finish = self.minutes_before_finish.minutes.to_i
        klass.validates :start_time,
                        timeliness: {
                          on_or_after: ->(r) { r.finish_time - minutes_before_finish },
                          type: :datetime
                        },
                        allow_blank: true
      end

      if finish_to_now?
        klass.validates :finish_time,
                        timeliness: {
                          on_or_before: -> { Time.zone.now.change(sec: 0, usec: 0) + finish_time_minutes_offset },
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :finish_time,
                                -> (_) { Time.zone.now.change(sec: 0, usec: 0) + finish_time_minutes_offset },
                                allow_nil: false
        if fixed_finish_time
          klass.attr_readonly :finish_time
        end
      elsif finish_to_time?
        klass.validates :finish_time,
                        timeliness: {
                          on_or_before: finish_time,
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :finish_time,
                                finish_time,
                                allow_nil: false
        if fixed_finish_time
          klass.attr_readonly :finish_time
        end
      elsif finish_to_minutes_since_start?
        minutes_since_start = self.minutes_since_start.minutes.to_i
        klass.validates :finish_time,
                        timeliness: {
                          on_or_before: ->(r) { r.start_time + minutes_since_start },
                          type: :datetime
                        },
                        allow_blank: true
      end

      if minimum_distance > 0
        minimum_distance_minutes = minimum_distance.minutes
        if fixed_start_time || start_from_now? || start_from_time? || finish_to_minutes_since_start?
          klass.validates :finish_time,
                          timeliness: {
                            on_or_after: ->(r) { r.start_time + minimum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false
        elsif fixed_finish_time || finish_to_now? || finish_to_time? || start_from_minutes_before_finish?
          klass.validates :start_time,
                          timeliness: {
                            on_or_before: ->(r) { r.finish_time - minimum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false
        else
          klass.validates :finish_time,
                          timeliness: {
                            on_or_after: ->(r) { r.start_time + minimum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false
        end
      end

      if maximum_distance > 0
        maximum_distance_minutes = maximum_distance.minutes
        if fixed_start_time || start_from_now? || start_from_time? || finish_to_minutes_since_start?
          klass.validates :finish_time,
                          timeliness: {
                            on_or_before: ->(r) { r.start_time + maximum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false
        elsif fixed_finish_time || finish_to_now? || finish_to_time? || start_from_minutes_before_finish?
          klass.validates :finish_time,
                          timeliness: {
                            on_or_after: ->(r) { r.finish_time - maximum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false
        else
          klass.validates :finish_time,
                          timeliness: {
                            on_or_before: ->(r) { r.start_time + maximum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false
        end
      end
    end
  end
end
