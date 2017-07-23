class Fields::ApplicationController < ApplicationController
  before_action :set_field

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_field
    @field = FormCore::Field.find(params[:field_id])
  end

  def fields_url
    form = @field.form

    case form
    when Form
      form_fields_url(form)
    when NestedForm
      nested_form_fields_url(form)
    else
      raise "Unknown form: #{form.class}"
    end
  end
end
