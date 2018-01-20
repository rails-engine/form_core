# frozen_string_literal: true

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

  def set_preview
    @preview = @form.to_virtual_model
  end

  def serialized_form_data
    params.fetch(:serialized, "")
  end
end
