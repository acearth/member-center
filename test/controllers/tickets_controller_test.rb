require 'test_helper'

class TicketsControllerTest < ActionDispatch::IntegrationTest

  test "should get user info by post ticket to auth" do
    # post login_url, params: {user}
    # ticket = Ticket.create({service_provider: ServiceProvider.first,
    #                         user: User.first,
    #                         request_ip: '127.0.0.1'})
    #
    # post auth_url, params: {ticket: ticket.par_value, sign: ticket.sign}
    # assert_response :success
  end

end
