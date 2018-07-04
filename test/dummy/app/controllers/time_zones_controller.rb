# frozen_string_literal: true

class TimeZonesController < ApplicationController
  def update
    @time_zone = ActiveSupport::TimeZone[params[:time_zone]]
    unless @time_zone
      return render :not_found
    end

    session[:current_time_zone] = params[:time_zone]

    redirect_back fallback_location: root_url
  end
end
