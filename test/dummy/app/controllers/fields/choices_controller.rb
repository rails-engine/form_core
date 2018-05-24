# frozen_string_literal: true

class Fields::ChoicesController < Fields::ApplicationController
  before_action :require_attach_choices!
  before_action :set_choice, only: %i[edit update destroy]

  def new
    @choice = @field.choices.build
  end

  def create
    @choice = @field.choices.build choice_params
    if @choice.save
      redirect_to field_choices_url(@field)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @choice.update choice_params
      redirect_to field_choices_url(@field)
    else
      render :edit
    end
  end

  def destroy
    @choice.destroy
    redirect_to field_choices_url(@field)
  end

  private

  def require_attach_choices!
    unless @field.attach_choices?
      redirect_to fields_url
    end
  end

  def choice_params
    params.require(:choice).permit(:label)
  end

  def set_choice
    @choice = @field.choices.find(params[:id])
  end
end
