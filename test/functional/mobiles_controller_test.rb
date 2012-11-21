require 'test_helper'

class MobilesControllerTest < ActionController::TestCase
  test "should get android" do
    get :android
    assert_response :success
  end

end
