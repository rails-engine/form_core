# frozen_string_literal: true

module Fields::Options
  class DateRangeField < FieldOptions
    attribute :begin_from, :string, default: "unlimited"
    enum begin_from: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_before_end: "days_before_end"
    }, _prefix: :begin_from

    attribute :begin, :date
    attribute :fixed_begin, :boolean, default: false
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
    attribute :fixed_end, :boolean, default: false
    attribute :nullable_end, :boolean, default: false
    attribute :end_to_today_days_offset, :integer, default: 0
    attribute :days_since_begin, :integer, default: 1

    attribute :minimum_distance, :integer, default: 0
    attribute :maximum_distance, :integer, default: 0

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
              exclusion: { in: %w[today] },
              if: [:begin_from_today?]

    validates :end_to,
              exclusion: { in: %w[days_since_begin] },
              if: [:begin_from_days_before_end?]

    validates :fixed_end,
              absence: true,
              if: [:fixed_begin]

    validates :fixed_begin,
              absence: true,
              if: ->(r) { r.begin_from_days_before_end? || r.begin_from_unlimited? }

    validates :fixed_end,
              absence: true,
              if: ->(r) { r.end_to_days_since_begin? || r.end_to_unlimited? }

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

      if begin_from_today?
        begin_days_offset = begin_from_today_days_offset.days.to_i

        klass.validates :begin,
                        timeliness: {
                          on_or_after: -> { Time.zone.today + begin_days_offset },
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :begin,
                                ->(_) { Time.zone.today + begin_days_offset },
                                allow_nil: nullable_begin
        klass.attr_readonly :begin if fixed_begin
      elsif begin_from_date?
        klass.validates :begin,
                        timeliness: {
                          on_or_after: self.begin,
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :begin,
                                self.begin,
                                allow_nil: nullable_begin
        klass.attr_readonly :begin if fixed_begin
      elsif begin_from_days_before_end?
        days_before_end = self.days_before_end.days.to_i
        klass.validates :begin,
                        timeliness: {
                          on_or_after: ->(r) { r.end - days_before_end },
                          type: :date
                        },
                        allow_blank: true
      end

      if end_to_today?
        end_days_offset = end_to_today_days_offset.days.to_i

        klass.validates :end,
                        timeliness: {
                          on_or_before: -> { Time.zone.today + end_days_offset },
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :end,
                                ->(_) { Time.zone.today + end_days_offset },
                                allow_nil: false
        klass.attr_readonly :end if fixed_end
      elsif end_to_date?
        klass.validates :end,
                        timeliness: {
                          on_or_before: self.end,
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :end,
                                self.end,
                                allow_nil: false
        klass.attr_readonly :end if fixed_end
      elsif end_to_days_since_begin?
        days_since_begin = self.days_since_begin.days.to_i
        klass.validates :end,
                        timeliness: {
                          on_or_before: ->(r) { r.begin + days_since_begin },
                          type: :date
                        },
                        allow_blank: true
      end

      if minimum_distance.positive?
        minimum_distance_days = minimum_distance.days
        if fixed_begin || begin_from_today? || begin_from_date? || end_to_days_since_begin?
          klass.validates :end,
                          timeliness: {
                            on_or_after: ->(r) { r.begin + minimum_distance_days },
                            type: :date
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:begin).present? }
        elsif fixed_end || end_to_today? || end_to_date? || begin_from_days_before_end?
          klass.validates :begin,
                          timeliness: {
                            on_or_before: ->(r) { r.end - minimum_distance_days },
                            type: :date
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:end).present? }
        else
          klass.validates :end,
                          timeliness: {
                            on_or_after: ->(r) { r.begin + minimum_distance_days },
                            type: :date
                          },
                          allow_blank: false,
                          if: -> { read_attribute(:begin).present? }
        end
      end

      if maximum_distance.positive?
        maximum_distance_days = maximum_distance.days
        if fixed_begin || begin_from_today? || begin_from_date? || end_to_days_since_begin?
          klass.validates :end,
                          timeliness: {
                            on_or_before: ->(r) { r.begin + maximum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        elsif fixed_end || end_to_today? || end_to_date? || begin_from_days_before_end?
          klass.validates :end,
                          timeliness: {
                            on_or_after: ->(r) { r.end - maximum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        else
          klass.validates :end,
                          timeliness: {
                            on_or_before: ->(r) { r.begin + maximum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        end
      end
    end
  end
end
