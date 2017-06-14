require 'test_helper'

class Api::V1::GeniusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.first
    @sp = ServiceProvider.first
  end

  test "should get user info by post ticket to auth" do
    ticket = Ticket.new(service_provider: @sp, user: @user)
    ticket.save!
    sp_sign = CommonUtils.md5_sign(@sp.app_id, ticket.par_value, @sp.credential)
    post api_v1_auth_path, params: {ticket: ticket.par_value, app_id: @sp.app_id, sign: sp_sign}
    got = JSON.parse(response.body)
    assert_equal 0, got['status']['code']
    assert_equal @user.email, got['user']['email']
  end

  test 'should log in success with right user_name and password by post directly' do
    password = 'password'
    sp_sign = CommonUtils.md5_sign(@sp.app_id, @user.user_name, password, @sp.credential)
    post api_v1_login_path, params: {app_id: @sp.app_id, user_name: @user.user_name, password: password, sign: sp_sign}
    got = JSON.parse(response.body)
    assert_equal 0, got['status']['code']
    assert_equal @user.email, got['user']['email']
  end
end
