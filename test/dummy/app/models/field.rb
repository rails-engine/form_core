# frozen_string_literal: true

class Field < ApplicationRecord
  include FormCore::Concerns::Models::Field

  self.table_name = "fields"

  belongs_to :form, class_name: "MetalForm", foreign_key: "form_id", touch: true

  belongs_to :section, touch: true, optional: true

  has_many :choices, -> { order(position: :asc) }, dependent: :destroy, autosave: true

  acts_as_list scope: [:section_id]

  validates :label,
            presence: true
  validates :type,
            inclusion: {
              in: ->(_) { Field.descendants.map(&:to_s) }
            },
            allow_blank: false

  default_value_for :name,
                    ->(_) { "field_#{SecureRandom.hex(3)}" },
                    allow_nil: false

  def self.type_key
    model_name.name.split("::").last.underscore
  end

  def type_key
    self.class.type_key
  end

  def options_configurable?
    options.is_a?(FieldOptions) && options.attributes.any?
  end

  def validations_configurable?
    validations.is_a?(FieldOptions) && validations.attributes.any?
  end

  def attached_choices?
    false
  end

  def attached_data_source?
    false
  end

  def attached_nested_form?
    false
  end

  protected

  def interpret_validations_to(model, accessibility, overrides = {})
    return unless accessibility == :read_and_write

    validations_overrides = overrides.fetch(:validations) { {} }
    validations =
      if validations_overrides.any?
        self.validations.dup.update(validations_overrides)
      else
        self.validations
      end

    validations.interpret_to(model, name, accessibility)
  end

  def interpret_extra_to(model, accessibility, overrides = {})
    options_overrides = overrides.fetch(:options) { {} }
    options =
      if options_overrides.any?
        self.options.dup.update(options_overrides)
      else
        self.options
      end

    options.interpret_to(model, name, accessibility)
  end
end

require_dependency "fields"
