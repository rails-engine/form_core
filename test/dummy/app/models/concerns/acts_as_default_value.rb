# frozen_string_literal: true

# https://github.com/FooBarWidget/default_value_for
#
# Copyright (c) 2008-2012 Phusion
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module ActsAsDefaultValue
  extend ActiveSupport::Concern

  class NormalValueContainer
    def initialize(value)
      @value = value
    end

    def evaluate(_instance)
      if @value.duplicable?
        @value.dup
      else
        @value
      end
    end
  end

  class BlockValueContainer
    def initialize(block)
      @block = block
    end

    def evaluate(instance)
      if @block.arity == 0
        @block.call
      else
        @block.call(instance)
      end
    end
  end

  included do
    after_initialize :set_default_values
  end

  def initialize(attributes = nil)
    @initialization_attributes = attributes.is_a?(Hash) ? attributes.stringify_keys : {}
    super
  end

  def set_default_values
    self.class._all_default_attribute_values.each do |attribute, container|
      next unless new_record? || self.class._all_default_attribute_values_not_allowing_nil.include?(attribute)

      connection_default_value_defined = new_record? && respond_to?("#{attribute}_changed?") && !send("#{attribute}_changed?")

      column = self.class.columns.detect { |c| c.name == attribute }
      attribute_blank =
        if column && column.type == :boolean
          send(attribute).nil?
        else
          send(attribute).blank?
        end
      next unless connection_default_value_defined || attribute_blank

      # allow explicitly setting nil through allow nil option
      next if @initialization_attributes.is_a?(Hash) &&
        (
        @initialization_attributes.has_key?(attribute) ||
          (
          @initialization_attributes.has_key?("#{attribute}_attributes") &&
            nested_attributes_options.stringify_keys[attribute]
          )
        ) &&
        !self.class._all_default_attribute_values_not_allowing_nil.include?(attribute)

      send("#{attribute}=", container.evaluate(self))

      clear_attribute_changes [attribute] if has_attribute?(attribute)
    end
  end

  def attributes_for_create(attribute_names)
    attribute_names += self.class._all_default_attribute_values.keys.map(&:to_s).find_all do |name|
      self.class.columns_hash.key?(name)
    end

    super
  end

  module ClassMethods
    def _default_attribute_values # :nodoc:
      @default_attribute_values ||= {}
    end

    def _default_attribute_values_not_allowing_nil # :nodoc:
      @default_attribute_values_not_allowing_nil ||= Set.new
    end

    def _all_default_attribute_values # :nodoc:
      if superclass.respond_to?(:_default_attribute_values)
        superclass._all_default_attribute_values.merge(_default_attribute_values)
      else
        _default_attribute_values
      end
    end

    def _all_default_attribute_values_not_allowing_nil # :nodoc:
      if superclass.respond_to?(:_default_attribute_values_not_allowing_nil)
        superclass._all_default_attribute_values_not_allowing_nil + _default_attribute_values_not_allowing_nil
      else
        _default_attribute_values_not_allowing_nil
      end
    end

    # Declares a default value for the given attribute.
    #
    # Sets the default value to the given options parameter
    #
    # The <tt>options</tt> can be used to specify the following things:
    # * <tt>allow_nil (default: true)</tt> - Sets explicitly passed nil values if option is set to true.
    def default_value_for(attribute, value, **options)
      allow_nil = options.fetch(:allow_nil, true)

      container =
        if value.is_a? Proc
          BlockValueContainer.new(value)
        else
          NormalValueContainer.new(value)
        end

      _default_attribute_values[attribute.to_s] = container
      _default_attribute_values_not_allowing_nil << attribute.to_s unless allow_nil

      attribute
    end
  end
end
