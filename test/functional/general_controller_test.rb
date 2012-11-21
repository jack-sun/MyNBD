require 'test_helper'

class GeneralControllerTest < ActionController::TestCase
  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end

  test "should get copyright" do
    get :copyright
    assert_response :success
  end

  test "should get advertisement" do
    get :advertisement
    assert_response :success
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

  test "should get links" do
    get :links
    assert_response :success
  end

  test "should get sitemap" do
    get :sitemap
    assert_response :success
  end

end
