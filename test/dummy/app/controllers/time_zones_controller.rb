# frozen_string_literal: true

class TimeZonesController < ApplicationController
  def update
    @time_zone = ActiveSupport::TimeZone[params[:time_zone]]
    return render :not_found unless @time_zone

    session[:current_time_zone] = params[:time_zone]

    redirect_back fallback_location: root_url
  end
end
