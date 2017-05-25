require 'test_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest
  test "should get auth" do
    post auth_url
    assert_response :success
  end

end
