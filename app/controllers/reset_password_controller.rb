class ResetPasswordController < ApplicationController
  def new
  end

  def create
    user = User.find_by_user_name(params[:user_name])
    if UserSecurity.valid_otp?(user, params[:otp_code])
      user.update(password: params[:new_password])
      flash[:notice] = 'Your password has been changed successfully'
    else
      flash[:warning] = 'Invalid user or verification code'
    end
  end
end
