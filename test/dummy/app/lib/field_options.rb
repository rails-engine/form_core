# frozen_string_literal: true

class FieldOptions < DuckRecord::Base
  include EnumTranslate

  def interpret_to(_model, _field_name, _accessibility, _options = {})
  end

  def serializable_hash(options = {})
    options = (options || {}).reverse_merge include: _reflections.keys
    super options
  end

  class << self
    WHITELIST_CLASSES = [BigDecimal, Date, Time]

    def dump(obj)
      YAML.dump(obj&.to_h || {})
    end

    def load(yaml)
      return new if yaml.blank?

      unless yaml.is_a?(String) && /^---/.match?(yaml)
        return new
      end

      decoded = YAML.safe_load(yaml, WHITELIST_CLASSES)
      unless decoded.is_a? Hash
        return new
      end

      new decoded.slice(*(attribute_names + reflections.keys))
    end
  end
end
