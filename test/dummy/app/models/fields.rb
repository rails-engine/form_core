# frozen_string_literal: true

module Fields
  %w[
  text boolean decimal integer resource
  date datetime
  resource_select select multiple_select
  variable_length_nested_form
  ].each do |type|
    require_dependency "fields/#{type}_field"
  end
end
