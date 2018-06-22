# frozen_string_literal: true

module Fields
  %w[
  text boolean decimal integer
  date datetime
  attachment multiple_attachment
  time_span
  choice multiple_choice
  resource_select multiple_resource_select
  select multiple_select
  nested_form multiple_nested_form
  ].each do |type|
    require_dependency "fields/#{type}_field"
  end
end
