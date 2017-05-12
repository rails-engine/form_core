class Forms::ApplicationController < ApplicationController
  layout 'forms'

  before_action :set_form

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_form
    @form = Form.find(params[:form_id])
  end
end
