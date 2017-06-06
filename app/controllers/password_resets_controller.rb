class PasswordResetsController < ApplicationController
  include CommonUtils
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
        UserMailer.password_reset(user, reset_url(user)).deliver_now
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
    @user = set_email_user(params[:reset_info])
    return unless @user
    @user.update(password: params[:reset_info][:password])
  end

  private

  def set_otp_user
    user = User.find_by_user_name(params[:reset_form][:user_name])
    return user if user && UserSecurity.valid_otp?(user, params[:reset_form][:otp_code])
  end

  def reset_url(user)
    reset_token = aes_encrypt(user.credential[0...16], "#{Time.now.to_i}-#{user.user_name}")
    query = {
        reset_token: reset_token,
        email: user.email,
        sign: signature(reset_token, user.email, user.credential)
    }
    "#{edit_password_resets_url.strip}?#{query.to_query}"
  end


  def set_email_user(info)
    user = User.find_by_email(info[:email])
    unless valid_sign?(info[:reset_token], info[:email], user.credential, info[:sign])
      flash[:warning] = 'Bad request!'
      redirect_to new_password_reset_path and return
    end
    msg = aes_decrypt(user.credential[0...16], info[:reset_token])
    issue_time, user_name = msg.split('-')
    unless expired?(issue_time)
      flash[:warning] = 'Link expired! Please resubmit your request again'
      redirect_to new_password_reset_path and return
    end
    if user_name != user.user_name
      flash[:warning] = 'Bad request! parameters broken'
      redirect_to new_password_reset_path and return
    end
    user
  end

  def expired?(issue_time)
    issue_time.to_i > 30.minutes.ago.to_i
  end
end
