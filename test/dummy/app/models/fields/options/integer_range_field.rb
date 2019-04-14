# frozen_string_literal: true

module Fields::Options
  class IntegerRangeField < FieldOptions
    attribute :begin_from, :string, default: "unrestricted"
    enum begin_from: {
      unrestricted: "unrestricted",
      value: "value",
      offsets_before_end: "offsets_before_end"
    }, _prefix: :begin_from

    attribute :begin_value, :integer
    attribute :fixed_begin, :boolean, default: false
    attribute :offsets_before_end, :integer, default: 1

    attribute :end_to, :string, default: "unrestricted"
    enum end_to: {
      unrestricted: "unrestricted",
      value: "value",
      offsets_since_begin: "offsets_since_begin"
    }, _prefix: :end_to

    attribute :end_value, :integer
    attribute :fixed_end, :boolean, default: false
    attribute :offsets_since_begin, :integer, default: 1

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

    validates :begin_from, :end_to,
              presence: true

    validates :begin_value,
              presence: true,
              if: :begin_from_value?

    validates :end_value,
              presence: true,
              if: :end_to_value?

    validates :offsets_before_end,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :begin_from_offsets_before_end?

    validates :offsets_since_begin,
              numericality: {
                only_integer: true,
                greater_than: 0
              },
              allow_blank: false,
              if: :end_to_offsets_since_begin?

    validates :end_value,
              numericality: {
                only_integer: true,
                greater_than: :begin_value
              },
              allow_blank: false,
              if: %i[begin_from_value? end_to_value?]

    validates :end_to,
              exclusion: {in: %w[offsets_since_begin]},
              if: [:begin_from_offsets_before_end?]

    validates :fixed_end,
              absence: true,
              if: [:fixed_begin]

    validates :fixed_begin,
              absence: true,
              if: ->(r) { r.begin_from_offsets_before_end? || r.begin_from_unrestricted? }

    validates :fixed_end,
              absence: true,
              if: ->(r) { r.end_to_offsets_since_begin? || r.end_to_unrestricted? }

    validates :begin_value, :end_value,
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

      if begin_from_value?
        klass.validates :begin,
                        numericality: {
                          greater_than_or_equal_to: begin_value
                        },
                        allow_blank: true
        if fixed_begin
          klass.default_value_for :begin,
                                  begin_value,
                                  allow_nil: false
          klass.attr_readonly :begin
        end
      elsif begin_from_offsets_before_end?
        klass.validates :begin,
                        numericality: {
                          greater_than_or_equal_to: ->(r) { r.end - offsets_before_end }
                        },
                        allow_blank: true
      end

      if end_to_value?
        klass.validates :end,
                        numericality: {
                          less_than_or_equal_to: end_value
                        },
                        allow_blank: true
        if fixed_end
          klass.default_value_for :end,
                                  end_value,
                                  allow_nil: false
          klass.attr_readonly :end
        end
      elsif end_to_offsets_since_begin?
        klass.validates :end,
                        numericality: {
                          less_than_or_equal_to: ->(r) { r.begin + offsets_since_begin }
                        },
                        allow_blank: true
      end

      unless minimum_gap_check_unrestricted?
        klass.validates :end,
                        numericality: {
                          minimum_gap_check.to_sym => ->(r) { r.begin + minimum_gap_value }
                        },
                        allow_blank: false
      end

      unless maximum_gap_check_unrestricted?
        klass.validates :end,
                        numericality: {
                          maximum_gap_check.to_sym => ->(r) { r.begin + maximum_gap_value }
                        },
                        allow_blank: false
      end
    end
  end
end
