require 'test_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest
  test "should get auth" do
    get tickets_auth_url
    assert_response :success
  end

end
