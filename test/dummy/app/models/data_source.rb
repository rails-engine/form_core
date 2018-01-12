# frozen_string_literal: true

class DataSource < FieldOptions
  def type_key
    self.class.type_key
  end

  def source_class
    raise NotImplementedError
  end

  def stored_type
    :integer
  end

  def foreign_field_name_suffix
    "_id"
  end

  def foreign_field_name(field_name)
    "#{field_name}#{foreign_field_name_suffix}"
  end

  def value_method
    :id
  end

  def text_method
    raise NotImplementedError
  end

  def scoped_condition
    self.serializable_hash
  end

  def scoped_records
    self.class.scoped_records(scoped_condition)
  end

  def interpret_to(model, field_name, accessibility, _options = {})
    if source_class
      where_condition = scoped_condition.dup
      model.belongs_to field_name, -> { where(where_condition) }, class_name: source_class.to_s, optional: true
    end
  end

  class << self
    def type_key
      model_name.name.split("::").last.underscore
    end

    def scoped_records(_condition)
      raise NotImplementedError
    end
  end
end

require_dependency "data_sources"
