class Field < FormCore::Field
  include EnumTranslate

  belongs_to :section, touch: true, optional: true

  validates :label,
            presence: true
  validates :type,
            inclusion: {
              in: ->(_) { Field.descendants.map(&:to_s) }
            }

  def type_key
    self.class.model_name.name.split("::").last.underscore
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
