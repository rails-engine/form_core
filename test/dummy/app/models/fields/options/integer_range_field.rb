# frozen_string_literal: true

module Fields::Options
  class IntegerRangeField < FieldOptions
    attribute :start_from, :string, default: "unrestricted"
    enum start_from: {
      unrestricted: "unrestricted",
      value: "value",
      offsets_before_finish: "offsets_before_finish"
    }, _prefix: :start_from

    attribute :start_value, :integer
    attribute :fixed_start, :boolean, default: false
    attribute :offsets_before_finish, :integer, default: 1

    attribute :finish_to, :string, default: "unrestricted"
    enum finish_to: {
      unrestricted: "unrestricted",
      value: "value",
      offsets_since_start: "offsets_since_start"
    }, _prefix: :finish_to

    attribute :finish_value, :integer
    attribute :fixed_finish, :boolean, default: false
    attribute :offsets_since_start, :integer, default: 1

    attribute :minimum_gap_check, :string, default: "unrestricted"
    enum minimum_gap_check: {
      unrestricted: "unrestricted",
      greater_than: "greater_than",
      greater_than_or_equal_to: "greater_than_or_equal_to"
    }, _prefix: :minimum_gap_check

    attribute :maximum_gap_check, :string, default: "unrestricted"
    enum maximum_gap_check: {
      unrestricted: "unrestricted",
      less_than: "less_than",
      less_than_or_equal_to: "less_than_or_equal_to"
    }, _prefix: :maximum_gap_check

    attribute :minimum_gap_value, :integer, default: 0
    attribute :maximum_gap_value, :integer, default: 0

    validates :start_from, :finish_to,
              presence: true

    validates :start_value,
              presence: true,
              if: :start_from_value?

    validates :finish_value,
              presence: true,
              if: :finish_to_value?

    validates :offsets_before_finish,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :start_from_offsets_before_finish?

    validates :offsets_since_start,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :finish_to_offsets_since_start?

    validates :finish_value,
              numericality: {
                only_integer: true,
                greater_than: :start_value
              },
              allow_blank: false,
              if: %i[start_from_value? finish_to_value?]

    validates :finish_to,
              exclusion: {in: %w[offsets_since_start]},
              if: [:start_from_offsets_before_finish?]

    validates :fixed_finish,
              absence: true,
              if: [:fixed_start]

    validates :fixed_start,
              absence: true,
              if: ->(r) { r.start_from_offsets_before_finish? || r.start_from_unrestricted? }

    validates :fixed_finish,
              absence: true,
              if: ->(r) { r.finish_to_offsets_since_start? || r.finish_to_unrestricted? }

    validates :start_value, :finish_value,
              numericality: {
                only_integer: true
              },
              allow_blank: true

    validates :minimum_gap_value, :maximum_gap_value,
              numericality: {
                greater_than_or_equal_to: 0
              }

    validates :maximum_gap_value,
              numericality: {
                greater_than: :minimum_gap_value
              },
              unless: proc { maximum_gap_check_unrestricted? && minimum_gap_check_unrestricted? }

    def interpret_to(model, field_name, accessibility, _options = {})
      return unless accessibility == :read_and_write

      klass = model.nested_models[field_name]

      if start_from_value?
        klass.validates :start,
                        numericality: {
                          greater_than_or_equal_to: start_value
                        },
                        allow_blank: true
        if fixed_start
          klass.default_value_for :start,
                                  start_value,
                                  allow_nil: false
          klass.attr_readonly :start
        end
      elsif start_from_offsets_before_finish?
        klass.validates :start,
                        numericality: {
                          greater_than_or_equal_to: ->(r) { r.finish - offsets_before_finish }
                        },
                        allow_blank: true
      end

      if finish_to_value?
        klass.validates :finish,
                        numericality: {
                          less_than_or_equal_to: finish_value
                        },
                        allow_blank: true
        if fixed_finish
          klass.default_value_for :finish,
                                  finish_value,
                                  allow_nil: false
          klass.attr_readonly :finish
        end
      elsif finish_to_offsets_since_start?
        klass.validates :finish,
                        numericality: {
                          less_than_or_equal_to: ->(r) { r.start + offsets_since_start }
                        },
                        allow_blank: true
      end

      unless minimum_gap_check_unrestricted?
        klass.validates :finish,
                        numericality: {
                          minimum_gap_check.to_sym => ->(r) { r.start + minimum_gap_value }
                        },
                        allow_blank: false
      end

      unless maximum_gap_check_unrestricted?
        klass.validates :finish,
                        numericality: {
                          maximum_gap_check.to_sym => ->(r) { r.start + maximum_gap_value }
                        },
                        allow_blank: false
      end
    end
  end
end
