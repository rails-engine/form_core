# frozen_string_literal: true

module Fields
  %w[
    text boolean decimal integer
    date datetime
    choice multiple_choice
    select multiple_select
    integer_range decimal_range date_range datetime_range
    nested_form multiple_nested_form
    attachment multiple_attachment
    resource_select multiple_resource_select
    resource multiple_resource
  ].each do |type|
    require_dependency "fields/#{type}_field"
  end

  MAP = Hash[*Field.descendants.map { |f| [f.type_key, f] }.flatten]
end
