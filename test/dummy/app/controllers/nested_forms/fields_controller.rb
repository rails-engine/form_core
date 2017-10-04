# frozen_string_literal: true

class NestedForms::FieldsController < NestedForms::ApplicationController
  before_action :set_field, only: %i[show edit update destroy]

  def index
    @fields = @nested_form.fields.includes(:section).all
  end

  def new
    @field = @nested_form.fields.build
  end

  def edit
  end

  def create
    @field = @nested_form.fields.build(field_params)

    if @field.save
      redirect_to nested_form_fields_url(@nested_form), notice: "Field was successfully created."
    else
      render :new
    end
  end

  def update
    if @field.update(field_params)
      redirect_to nested_form_fields_url(@nested_form), notice: "Field was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @field.destroy
    redirect_to nested_form_fields_url(@nested_form), notice: "Field was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_field
    @field = @nested_form.fields.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def field_params
    params.fetch(:field, {}).permit(:name, :label, :hint, :prompt, :accessibility, :type)
  end
end
