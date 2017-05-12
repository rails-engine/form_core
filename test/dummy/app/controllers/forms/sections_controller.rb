class Forms::SectionsController < Forms::ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy]

  # GET /forms/1/sections
  def index
    @sections = @form.sections.all
  end

  # GET /forms/sections/new
  def new
    @section = @form.sections.build
  end

  # GET /forms/1/sections/1/edit
  def edit
  end

  # POST /forms/1/sections
  def create
    @section = @form.sections.build(section_params)

    if @section.save
      redirect_to form_sections_url(@form), notice: 'Section was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /forms/1/sections/1
  def update
    if @section.update(section_params)
      redirect_to form_sections_url(@form), notice: 'Section was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /forms/1/sections/1
  def destroy
    @section.destroy
    redirect_to form_sections_url(@form), notice: 'Section was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_section
    @section = @form.sections.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def section_params
    params.fetch(:section, {}).permit(:title)
  end
end
