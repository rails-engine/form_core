# frozen_string_literal: true

class FieldOptions < ActiveEntity::Base
  include FormCore::ActsAsDefaultValue
  include EnumAttributeLocalizable

  class_attribute :keeping_old_serialization

  attr_accessor :raw_attributes

  def interpret_to(_model, _field_name, _accessibility, _options = {}); end

  def serializable_hash(options = {})
    options = (options || {}).reverse_merge include: self.class._embeds_reflections.keys
    super options
  end

  private

    def _assign_attribute(k, v)
      if self.class._embeds_reflections.key?(k)
        public_send("#{k}_attributes=", v)
      elsif respond_to?("#{k}=")
        public_send("#{k}=", v)
      end
    end

    class << self
      def _embeds_reflections
        _reflections.select { |_, v| v.is_a? ActiveEntity::Reflection::EmbeddedAssociationReflection }
      end

      def model_version
        1
      end

      def root_key_for_serialization
        "#{self}.#{model_version}"
      end

      def dump(obj)
        return YAML.dump({}) unless obj

        serializable_hash =
          if obj.respond_to?(:serializable_hash)
            obj.serializable_hash
          elsif obj.respond_to?(:to_hash)
            obj.to_hash
          else
            raise ArgumentError, "`obj` required can be cast to `Hash` -- #{obj.class}"
          end.stringify_keys

        data = { root_key_for_serialization => serializable_hash }
        data.reverse_merge! obj.raw_attributes if keeping_old_serialization

        YAML.dump(data)
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

      WHITELIST_CLASSES = [BigDecimal, Date, Time, Symbol].freeze
      def load_from_yaml(yaml)
        return new if yaml.blank?

        return new unless yaml.is_a?(String) && /^---/.match?(yaml)

        decoded = YAML.safe_load(yaml, WHITELIST_CLASSES)
        return new unless decoded.is_a? Hash

        record = new decoded[root_key_for_serialization]
        record.raw_attributes = decoded.freeze
        record
      end

      def load_from_hash(hash)
        return new if hash.blank?

        record = new hash[root_key_for_serialization]
        record.raw_attributes = hash.freeze
        record
      end
    end
end
