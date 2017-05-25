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
      puts 'failed to login'
      render 'new'
    end
  end


  def destroy
    log_out if logged_in?
    redirect_to login_path
  end

  private

  def login_params(params)
    #todo-require-params
  end

  def login_back(app_id, member)
    if (app_id.present? && app = ApplicationProvider.find_by_app_id(app_id))
      ticket = Ticket.create(application_provider: app, member: member, login_ip: request.remote_ip)
      ticket.save
      return "#{format_query(app.callback_url)}&ticket=#{ticket.par_value}&sign=#{ticket.sign}"
    else
      return member
    end
  end
end
