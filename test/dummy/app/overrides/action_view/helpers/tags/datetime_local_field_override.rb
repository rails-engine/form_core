# frozen_string_literal: true

ActionView::Helpers::Tags::DatetimeLocalField.class_eval do
  def format_date(value)
    value&.in_time_zone&.strftime("%Y-%m-%dT%T")
  end
end
