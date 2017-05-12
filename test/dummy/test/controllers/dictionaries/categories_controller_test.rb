require 'test_helper'

class Dictionaries::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dictionaries_category = dictionaries_categories(:one)
  end

  test "should get index" do
    get dictionaries_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_dictionaries_category_url
    assert_response :success
  end

  test "should create dictionaries_category" do
    assert_difference('Dictionaries::Category.count') do
      post dictionaries_categories_url, params: { dictionaries_category: { value: @dictionaries_category.value } }
    end

    assert_redirected_to dictionaries_category_url(Dictionaries::Category.last)
  end

  test "should show dictionaries_category" do
    get dictionaries_category_url(@dictionaries_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_dictionaries_category_url(@dictionaries_category)
    assert_response :success
  end

  test "should update dictionaries_category" do
    patch dictionaries_category_url(@dictionaries_category), params: { dictionaries_category: { value: @dictionaries_category.value } }
    assert_redirected_to dictionaries_category_url(@dictionaries_category)
  end

  test "should destroy dictionaries_category" do
    assert_difference('Dictionaries::Category.count', -1) do
      delete dictionaries_category_url(@dictionaries_category)
    end

    assert_redirected_to dictionaries_categories_url
  end
end
