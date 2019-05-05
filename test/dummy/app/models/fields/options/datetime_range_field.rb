# frozen_string_literal: true

module Fields::Options
  class DatetimeRangeField < FieldOptions
    attribute :begin_from, :string, default: "unlimited"
    enum begin_from: {
      unlimited: "unlimited",
      now: "now",
      time: "time",
      minutes_before_end: "minutes_before_end"
    }, _prefix: :begin_from

    attribute :begin, :datetime
    attribute :fixed_begin, :boolean, default: false
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
    attribute :fixed_end, :boolean, default: false
    attribute :nullable_end, :boolean, default: false
    attribute :end_to_now_minutes_offset, :integer, default: 0
    attribute :minutes_since_begin, :integer, default: 1

    attribute :minimum_distance, :integer, default: 0
    attribute :maximum_distance, :integer, default: 0

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
              exclusion: { in: %w[now] },
              if: [:begin_from_now?]

    validates :end_to,
              exclusion: { in: %w[minutes_since_begin] },
              if: [:begin_from_minutes_before_end?]

    validates :fixed_end,
              absence: true,
              if: [:fixed_begin]

    validates :fixed_begin,
              absence: true,
              if: ->(r) { r.begin_from_minutes_before_end? || r.begin_from_unlimited? }

    validates :fixed_end,
              absence: true,
              if: ->(r) { r.end_to_minutes_since_begin? || r.end_to_unlimited? }

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
              unless: ->(r) { r.maximum_distance.to_i.zero? }

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      klass = model.nested_models[field_name]

      unless nullable_end
        klass.validates :end,
                        presence: true
      end

      if begin_from_now?
        begin_minutes_offset = begin_from_now_minutes_offset.minutes.to_i

        klass.validates :begin,
                        timeliness: {
                          on_or_after: -> { Time.zone.now.change(sec: 0, usec: 0) + begin_minutes_offset },
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :begin,
                                ->(_) { Time.zone.now.change(sec: 0, usec: 0) + begin_minutes_offset },
                                allow_nil: false
        klass.attr_readonly :begin if fixed_begin
      elsif begin_from_time?
        klass.validates :begin,
                        timeliness: {
                          on_or_after: self.begin,
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :begin,
                                self.begin,
                                allow_nil: false
        klass.attr_readonly :begin if fixed_begin
      elsif begin_from_minutes_before_end?
        minutes_before_end = self.minutes_before_end.minutes.to_i
        klass.validates :begin,
                        timeliness: {
                          on_or_after: ->(r) { r.end - minutes_before_end },
                          type: :datetime
                        },
                        allow_blank: true
      end

      if end_to_now?
        end_minutes_offset = end_to_now_minutes_offset.minutes.to_i

        klass.validates :end,
                        timeliness: {
                          on_or_before: -> { Time.zone.now.change(sec: 0, usec: 0) + end_minutes_offset },
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :end,
                                ->(_) { Time.zone.now.change(sec: 0, usec: 0) + end_minutes_offset },
                                allow_nil: false
        klass.attr_readonly :end if fixed_end
      elsif end_to_time?
        klass.validates :end,
                        timeliness: {
                          on_or_before: self.end,
                          type: :datetime
                        },
                        allow_blank: true
        klass.default_value_for :end,
                                self.end,
                                allow_nil: false
        klass.attr_readonly :end if fixed_end
      elsif end_to_minutes_since_begin?
        minutes_since_begin = self.minutes_since_begin.minutes.to_i
        klass.validates :end,
                        timeliness: {
                          on_or_before: ->(r) { r.begin + minutes_since_begin },
                          type: :datetime
                        },
                        allow_blank: true
      end

      if minimum_distance.positive?
        minimum_distance_minutes = minimum_distance.minutes
        if fixed_begin || begin_from_now? || begin_from_time? || end_to_minutes_since_begin?
          klass.validates :end,
                          timeliness: {
                            on_or_after: ->(r) { r.begin + minimum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:begin).present? }
        elsif fixed_end || end_to_now? || end_to_time? || begin_from_minutes_before_end?
          klass.validates :begin,
                          timeliness: {
                            on_or_before: ->(r) { r.end - minimum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:end).present? }
        else
          klass.validates :end,
                          timeliness: {
                            on_or_after: ->(r) { r.begin + minimum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:begin).present? }
        end
      end

      if maximum_distance.positive?
        maximum_distance_minutes = maximum_distance.minutes
        if fixed_begin || begin_from_now? || begin_from_time? || end_to_minutes_since_begin?
          klass.validates :end,
                          timeliness: {
                            on_or_before: ->(r) { r.begin + maximum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:begin).present? }
        elsif fixed_end || end_to_now? || end_to_time? || begin_from_minutes_before_end?
          klass.validates :end,
                          timeliness: {
                            on_or_after: ->(r) { r.end - maximum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:end).present? }
        else
          klass.validates :end,
                          timeliness: {
                            on_or_before: ->(r) { r.begin + maximum_distance_minutes },
                            type: :datetime
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:begin).present? }
        end
      end
    end
  end
end
