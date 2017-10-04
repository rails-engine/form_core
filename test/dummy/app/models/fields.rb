# frozen_string_literal: true

module Fields
  %w[
  boolean decimal integer text resource
  resource_select select multiple_select
  variable_length_nested_form
  ].each do |type|
    require_dependency "fields/#{type}_field"
  end
end
