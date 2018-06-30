ActionView::Helpers::Tags::DateField.class_eval do
  def format_date(value)
    value&.in_time_zone&.strftime("%Y-%m-%d")
  end
end
