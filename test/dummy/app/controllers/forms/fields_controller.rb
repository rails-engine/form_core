class Forms::FieldsController < Forms::ApplicationController
  before_action :set_field, only: [:show, :edit, :update, :destroy]

  # GET /forms/1/fields
  def index
    @fields = @form.fields.includes(:section).all
  end

  # GET /forms/fields/new
  def new
    @field = @form.fields.build
  end

  # GET /forms/1/fields/1/edit
  def edit
  end

  # POST /forms/1/fields
  def create
    @field = @form.fields.build(field_params)

    if @field.save
      redirect_to form_fields_url(@form), notice: 'Field was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /forms/1/fields/1
  def update
    if @field.update(field_params)
      redirect_to form_fields_url(@form), notice: 'Field was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /forms/1/fields/1
  def destroy
    @field.destroy
    redirect_to form_fields_url(@form), notice: 'Field was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_field
    @field = @form.fields.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def field_params
    params.fetch(:field, {}).permit(:name, :label, :hint, :prompt, :section_id, :accessibility, :type)
  end
end
