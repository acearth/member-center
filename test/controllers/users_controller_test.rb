require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(role: :inactive)
  end

  test 'user can be activated' do
    query = {
        email: @user.email,
        activate_token: CommonUtils.email_token('activate', @user)
    }
    assert_equal 'inactive', @user.role
    get activate_user_url(@user), params: query
  end
end
