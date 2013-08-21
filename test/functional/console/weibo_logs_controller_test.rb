require 'test_helper'

class Console::WeiboLogsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get banned" do
    get :banned
    assert_response :success
  end

  test "should get published" do
    get :published
    assert_response :success
  end

end
