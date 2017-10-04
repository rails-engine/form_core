# frozen_string_literal: true

class NestedForms::ApplicationController < ApplicationController
  before_action :set_nested_form

  protected

  # Use callbacks to share common setup or constraints between actions.
  def set_nested_form
    @nested_form = NestedForm.find(params[:nested_form_id])
  end
end
