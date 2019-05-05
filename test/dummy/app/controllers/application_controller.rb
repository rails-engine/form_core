# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :set_time_zone

  helper_method :current_time_zone

  private

    def set_time_zone(&block)
      Time.use_zone(current_time_zone, &block)
    end

    def current_time_zone
      @_current_time_zone ||=
        if session[:current_time_zone].present?
          ActiveSupport::TimeZone[session[:current_time_zone]] || ActiveSupport::TimeZone["UTC"]
        else
          ActiveSupport::TimeZone["UTC"]
        end
    end
end
