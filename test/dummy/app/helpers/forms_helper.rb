# frozen_string_literal: true

module FormsHelper
  def smart_form_fields_path(form)
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
