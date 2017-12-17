# frozen_string_literal: true

module Fields
  class IndexSelectField < Field
    serialize :validations, Validations::IndexSelectField
    serialize :options, Options::IndexSelectField

    def stored_type
      :integer
    end

    def collection
      options.collection.reject(&:blank?)
    end

    protected

    def interpret_extra_to(model, accessibility, overrides = {})
      super
      return if accessibility != :editable || collection.empty?
      model.validates name, inclusion: {in: 0..(collection.size - 1)}, allow_blank: true
    end
  end
end
