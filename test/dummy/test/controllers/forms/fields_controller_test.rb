require 'test_helper'

class Forms::FieldsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @field = forms_fields(:one)
  end

  test "should get index" do
    get forms_fields_url
    assert_response :success
  end

  test "should get new" do
    get new_forms_field_url
    assert_response :success
  end

  test "should create forms_field" do
    assert_difference('Forms::Field.count') do
      post forms_fields_url, params: {field: {  } }
    end

    assert_redirected_to forms_field_url(Forms::Field.last)
  end

  test "should show forms_field" do
    get forms_field_url(@field)
    assert_response :success
  end

  test "should get edit" do
    get edit_forms_field_url(@field)
    assert_response :success
  end

  test "should update forms_field" do
    patch forms_field_url(@field), params: {field: {  } }
    assert_redirected_to forms_field_url(@field)
  end

  test "should destroy forms_field" do
    assert_difference('Forms::Field.count', -1) do
      delete forms_field_url(@field)
    end

    assert_redirected_to forms_fields_url
  end
end
