ActionView::Base.field_error_proc = Proc.new do |html_tag, _instance|
  if html_tag =~ /<(input|label|textarea|select)/
    html_field = Nokogiri::HTML::DocumentFragment.parse(html_tag)
    html_field.children.add_class "is-danger"
    html_field.to_s.html_safe
  else
    html_tag.html_safe
  end
end
