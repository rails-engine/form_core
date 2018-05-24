# frozen_string_literal: true

module FieldsHelper
  def options_for_field_types(selected: nil)
    options_for_select(Field.descendants.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def options_for_data_source_types(selected: nil)
    options_for_select(DataSource.descendants.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def data_source_attached_field?(field)
    field.respond_to?(:data_source)
  end

  def nested_form_attached_field?(field)
    field.respond_to?(:nested_form)
  end

  def field_label(form, field_name:)
    field_name = field_name.to_s.split(".").first.to_sym

    form.fields.select do |field|
      field.name == field_name
    end.first&.label
  end

  def fields_path
    form = @field.form

    case form
    when Form
      form_fields_path(form)
    when NestedForm
      nested_form_fields_path(form)
    else
      raise "Unknown form: #{form.class}"
    end
  end
end
