# frozen_string_literal: true

class Forms::PreviewsController < Forms::ApplicationController
  before_action :eager_load_fields_and_sections
  before_action :set_preview

  def show
    @instance = @preview.new
  end

  def create
    @instance = @preview.new(preview_params)
    if @instance.valid?
      render :create
    else
      render :show
    end
  end

  private

  def eager_load_fields_and_sections
    @form.fields.find_all
    @form.sections.find_all

    grouped_fields = @form.fields.group_by(&:section_id)
    @form.sections.each do |section|
      association = section.fields.instance_variable_get(:@association)
      association.target.concat grouped_fields.fetch(section.id, [])
      association.loaded!
    end
  end

  def set_preview
    @preview = @form.to_virtual_model
  end

  def preview_params
    params.fetch(:preview, {}).permit!
  end
end
