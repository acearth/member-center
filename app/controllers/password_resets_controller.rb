class PasswordResetsController < ApplicationController
  include ActiveRecord::Validations

  validates :password, presence: true, confirmation: true, on: :update

  def new
    if current_user
      flash[:warning] = 'You have logged in!'
      redirect_to root_url
    end
  end

  def create
    if params[:reset_form][:reset_way] == 'email'
      if user = User.find_by_email(params[:reset_form][:email])
        UserMailer.password_reset(user,edit_password_resets_url).deliver_later
        flash[:warning] = 'Password reset email has been sent. Please check your mailbox.'
      else
        flash[:warning] = 'No corresponding user found.'
      end
      redirect_to root_url
    elsif params[:reset_form][:reset_way] == 'otp'
      if user = set_otp_user
        user.update(password: params[:reset_form][:new_password])
        flash[:notice] = 'Your password has been update successfully.'
        redirect_to login_path
      else
        flash[:warning] = 'Wrong user name or verfication code'
        redirect_to new_password_reset_path
      end
    end
  end

  def edit
  end


  def update
    @user = set_user(params[:reset_info])
    if @user
      @user.update(password: params[:reset_info][:password])
    else
      flash[:warning] ='Failed to reset password' unless @user
    end
    redirect_to login_path
  end

  private

  def set_otp_user
    user = User.find_by_user_name(params[:reset_form][:user_name])
    return user if user && UserSecurity.valid_otp?(user, params[:reset_form][:otp_code])
  end

  def set_user(info)
    user = User.find_by_email(info[:email])
    user && CommonUtils.valid_email_token?('password_reset', info[:reset_token], user) && user
  end
end
