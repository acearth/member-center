require 'test_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest
  test "should get auth" do
    post auth_url
    assert_response :success
  end

  test "should get user info by post ticket to auth" do
    post login_url, params: {user}

    post auth_url, params: {ticket: :xxxx, sign: :xxxx}
    assert_response :success
  end

end
