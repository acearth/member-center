class SessionsController < ApplicationController
  include SessionsHelper
  include CommonUtils

  def new
    redirect_to login_back(params[:app_id], current_user) if current_user
  end

  def create
    user = User.find_by(user_name: params[:session][:user_name])
    if user && user.authenticate(params[:session][:password])
      log_in user
      remember user
      redirect_to login_back(params[:session][:app_id], user)
    else
      flash[:warning] = I18n.t('wrong_user_or_password')
      render 'new'
    end
  end


  def destroy
    log_out if logged_in?
    redirect_to login_path
  end

  private

  def login_params(params)
    params.require(params[:session]).permit(:user_name, :password, :app_id)
  end

  def login_back(app_id, member)
    if (app_id.present? && app = ApplicationProvider.find_by_app_id(app_id))
      ticket = Ticket.create(service_provider: app, user: member, login_ip: request.remote_ip)
      ticket.save
      return "#{format_query(app.callback_url)}&ticket=#{ticket.par_value}&sign=#{ticket.sign}"
    else
      return member
    end
  end
end
