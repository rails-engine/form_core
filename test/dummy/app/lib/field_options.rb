# frozen_string_literal: true

class FieldOptions < DuckRecord::Base
  include EnumTranslate

  attr_accessor :_raw_attributes

  def interpret_to(_model, _field_name, _accessibility, _options = {})
  end

  def serializable_hash(options = {})
    options = (options || {}).reverse_merge include: _embeds_reflections.keys
    super options
  end

  def _embeds_reflections
    _reflections.select { |_, v| v.is_a? DuckRecord::Reflection::EmbedsAssociationReflection }
  end
  private :_embeds_reflections

  class << self
    WHITELIST_CLASSES = [BigDecimal, Date, Time, Symbol]

    def dump(obj)
      return YAML.dump({}) unless obj

      data =
        if obj.respond_to?(:serializable_hash)
          obj.serializable_hash
        elsif obj.respond_to?(:to_hash)
          obj.to_hash
        else
          raise ArgumentError, "`obj` required can be cast to `Hash` -- #{obj.class}"
        end.stringify_keys
      YAML.dump(self.to_s => data)
    end

    def load(yaml_or_hash)
      case yaml_or_hash
      when Hash
        load_from_hash(yaml_or_hash)
      when String
        load_from_yaml(yaml_or_hash)
      else
        new
      end
    end

    def load_from_yaml(yaml)
      return new if yaml.blank?

      unless yaml.is_a?(String) && /^---/.match?(yaml)
        return new
      end

      decoded = YAML.safe_load(yaml, WHITELIST_CLASSES)
      unless decoded.is_a? Hash
        return new
      end

      record = new decoded[self.to_s]&.slice(*(attribute_names + reflections.keys))
      record._raw_attributes = decoded.freeze
      record
    end

    def load_from_hash(hash)
      return new if hash.blank?
      record = new hash[self.to_s].slice(*(attribute_names + reflections.keys))
      record._raw_attributes = hash.freeze
      record
    end
  end
end
