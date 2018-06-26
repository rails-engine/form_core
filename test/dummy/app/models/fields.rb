# frozen_string_literal: true

module Fields
  %w[
  text boolean decimal integer
  date datetime
  datetime_range
  attachment multiple_attachment
  choice multiple_choice
  resource_select multiple_resource_select
  select multiple_select
  nested_form multiple_nested_form
  ].each do |type|
    require_dependency "fields/#{type}_field"
  end
end
