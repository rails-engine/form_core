# frozen_string_literal: true

class Fields::DataSourceOptionsController < Fields::ApplicationController
  before_action :require_data_source_options
  before_action :set_options

  def edit; end

  def update
    @options.assign_attributes(options_params)
    if @options.valid? && @field.save(validate: false)
      redirect_to fields_url, notice: "Field was successfully updated."
    else
      render :edit
    end
  end

  private

  def require_data_source_options
    unless @field.respond_to?(:data_source)
      redirect_to fields_url
    end
  end

  def set_options
    @options = @field.data_source
  end

  def options_params
    params.fetch(:options, {}).permit!
  end
end
