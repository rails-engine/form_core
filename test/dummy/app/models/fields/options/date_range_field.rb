# frozen_string_literal: true

module Fields::Options
  class DateRangeField < FieldOptions
    attribute :start_from, :string, default: "unlimited"
    enum start_from: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_before_finish: "days_before_finish"
    }, _prefix: :start_from

    attribute :start_date, :date
    attribute :fixed_start_date, :boolean, default: false
    attribute :start_from_today_days_offset, :integer, default: 0
    attribute :days_before_finish, :integer, default: 1

    attribute :finish_to, :string, default: "unlimited"
    enum finish_to: {
      unlimited: "unlimited",
      today: "today",
      date: "date",
      days_since_start: "days_since_start"
    }, _prefix: :finish_to

    attribute :finish_date, :date
    attribute :fixed_finish_date, :boolean, default: false
    attribute :finish_to_today_days_offset, :integer, default: 0
    attribute :days_since_start, :integer, default: 1

    attribute :minimum_distance, :integer, default: 0
    attribute :maximum_distance, :integer, default: 0

    validates :start_from, :finish_to,
              presence: true

    validates :start_date,
              presence: true,
              if: :start_from_date?

    validates :finish_date,
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

    validates :start_date,
              timeliness: {
                before: ->(r) { Time.zone.today + r.finish_to_today_days_offset.days },
                type: :date
              },
              allow_blank: false,
              if: [:start_from_date?, :finish_to_today?]

    validates :finish_date,
              timeliness: {
                after: -> { Time.zone.today + r.start_from_today_days_offset.days },
                type: :date
              },
              allow_blank: false,
              if: [:start_from_today?, :finish_to_date?]

    validates :finish_date,
              timeliness: {
                after: :start_date,
                type: :date
              },
              allow_blank: false,
              if: [:start_from_date?, :finish_to_date?]

    validates :finish_to,
              exclusion: {in: %w[today]},
              if: [:start_from_today?]

    validates :finish_to,
              exclusion: {in: %w[days_since_start]},
              if: [:start_from_days_before_finish?]

    validates :fixed_finish_date,
              absence: true,
              if: [:fixed_start_date]

    validates :fixed_start_date,
              absence: true,
              if: ->(r) { r.start_from_days_before_finish? || r.start_from_unlimited? }

    validates :fixed_finish_date,
              absence: true,
              if: ->(r) { r.finish_to_days_since_start? || r.finish_to_unlimited? }

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

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      klass = model.nested_models[field_name]

      if start_from_today?
        start_date_days_offset = self.start_from_today_days_offset.days.to_i

        klass.validates :start_date,
                        timeliness: {
                          on_or_after: -> { Time.zone.today + start_date_days_offset },
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :start_date,
                                -> (_) { Time.zone.today + start_date_days_offset },
                                allow_nil: false
        if fixed_start_date
          klass.attr_readonly :start_date
        end
      elsif start_from_date?
        klass.validates :start_date,
                        timeliness: {
                          on_or_after: start_date,
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :start_date,
                                start_date,
                                allow_nil: false
        if fixed_start_date
          klass.attr_readonly :start_date
        end
      elsif start_from_days_before_finish?
        days_before_finish = self.days_before_finish.days.to_i
        klass.validates :start_date,
                        timeliness: {
                          on_or_after: ->(r) { r.finish_date - days_before_finish },
                          type: :date
                        },
                        allow_blank: true
      end

      if finish_to_today?
        finish_date_days_offset = self.finish_to_today_days_offset.days.to_i

        klass.validates :finish_date,
                        timeliness: {
                          on_or_before: -> { Time.zone.today + finish_date_days_offset },
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :finish_date,
                                -> (_) { Time.zone.today + finish_date_days_offset },
                                allow_nil: false
        if fixed_finish_date
          klass.attr_readonly :finish_date
        end
      elsif finish_to_date?
        klass.validates :finish_date,
                        timeliness: {
                          on_or_before: finish_date,
                          type: :date
                        },
                        allow_blank: true
        klass.default_value_for :finish_date,
                                finish_date,
                                allow_nil: false
        if fixed_finish_date
          klass.attr_readonly :finish_date
        end
      elsif finish_to_days_since_start?
        days_since_start = self.days_since_start.days.to_i
        klass.validates :finish_date,
                        timeliness: {
                          on_or_before: ->(r) { r.start_date + days_since_start },
                          type: :date
                        },
                        allow_blank: true
      end

      if minimum_distance > 0
        minimum_distance_days = minimum_distance.days
        if fixed_start_date || start_from_today? || start_from_date? || finish_to_days_since_start?
          klass.validates :finish_date,
                          timeliness: {
                            on_or_after: ->(r) { r.start_date + minimum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        elsif fixed_finish_date || finish_to_today? || finish_to_date? || start_from_days_before_finish?
          klass.validates :start_date,
                          timeliness: {
                            on_or_before: ->(r) { r.finish_date - minimum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        else
          klass.validates :finish_date,
                          timeliness: {
                            on_or_after: ->(r) { r.start_date + minimum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        end
      end

      if maximum_distance > 0
        maximum_distance_days = maximum_distance.days
        if fixed_start_date || start_from_today? || start_from_date? || finish_to_days_since_start?
          klass.validates :finish_date,
                          timeliness: {
                            on_or_before: ->(r) { r.start_date + maximum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        elsif fixed_finish_date || finish_to_today? || finish_to_date? || start_from_days_before_finish?
          klass.validates :finish_date,
                          timeliness: {
                            on_or_after: ->(r) { r.finish_date - maximum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        else
          klass.validates :finish_date,
                          timeliness: {
                            on_or_before: ->(r) { r.start_date + maximum_distance_days },
                            type: :date
                          },
                          allow_blank: false
        end
      end
    end
  end
end
