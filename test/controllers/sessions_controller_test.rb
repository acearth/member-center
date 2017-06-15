require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @one_password = 'password'
    @user = User.last
    @user.update!(password: @one_password)
    @sp = ServiceProvider.last
  end

  test 'user can login directly' do
    post login_url, params: {session: {user_name: @user.user_name, password: @one_password}}
    assert_redirected_to @user
  end

  test 'user can login back to service_provider' do
    post login_url, params: {session: {user_name: @user.user_name, password: @one_password, app_id: @sp.app_id}}
    assert_response :redirect
    assert response.redirect_url.start_with?(@sp.callback_url)
  end
end
