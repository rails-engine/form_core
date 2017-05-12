require 'test_helper'

class Forms::PreviewControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get forms_preview_show_url
    assert_response :success
  end

  test "should get create" do
    get forms_preview_create_url
    assert_response :success
  end

end
