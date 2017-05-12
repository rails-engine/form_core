require 'test_helper'

class Forms::SectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @section = forms_sections(:one)
  end

  test "should get index" do
    get forms_sections_url
    assert_response :success
  end

  test "should get new" do
    get new_forms_section_url
    assert_response :success
  end

  test "should create forms_section" do
    assert_difference('Forms::Section.count') do
      post forms_sections_url, params: {section: {  } }
    end

    assert_redirected_to forms_section_url(Forms::Section.last)
  end

  test "should show forms_section" do
    get forms_section_url(@section)
    assert_response :success
  end

  test "should get edit" do
    get edit_forms_section_url(@section)
    assert_response :success
  end

  test "should update forms_section" do
    patch forms_section_url(@section), params: {section: {  } }
    assert_redirected_to forms_section_url(@section)
  end

  test "should destroy forms_section" do
    assert_difference('Forms::Section.count', -1) do
      delete forms_section_url(@section)
    end

    assert_redirected_to forms_sections_url
  end
end
