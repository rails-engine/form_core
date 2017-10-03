class Forms::LoadsController < Forms::ApplicationController
  before_action :eager_load_fields_and_sections, except: [:show]
  before_action :set_preview, except: [:show]

  def show
  end

  def create
    @instance = @preview.load(serialized_form_data)
    render :create
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

  def serialized_form_data
    params.fetch(:serialized, "")
  end
end
