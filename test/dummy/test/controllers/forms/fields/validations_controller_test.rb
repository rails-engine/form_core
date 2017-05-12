require 'test_helper'

class Forms::Fields::ValidationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get forms_fields_validation_show_url
    assert_response :success
  end

end
