class SessionsController < ApplicationController
  include SessionsHelper

  before_action :set_third_party, only: [:new, :create]

  def new
    redirect_to login_back(current_user) and return if current_user
    render layout: false
  end

  def create
    info = params.require(:session).permit(:user_name, :password, :remember_me, :app_id)
    user = User.find_by_user_name(info[:user_name])
    if user && user.authenticate(info[:password])
      if  !user.invalid_role? || user.user_name.start_with?('test')
        log_in user
        remember user if info[:remember_me]
        redirect_to login_back(user)
      else
        flash[:warning] = 'User not activated. Please check your email later.'
        UserMailer.activate(user, activate_user_url(user)).deliver_later
        redirect_to root_path
      end
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

  def set_third_party
    app_id = params[:app_id] || params[:session] && params[:session][:app_id]
    if app_id.present?
      @service_provider = ServiceProvider.find_by_app_id(app_id)
      unless @service_provider
        flash[:warning] = 'Wrong service provider parameter'
        redirect_to root_url
      end
    end
  end

  def login_back(user)
    foreign_params = request.query_parameters.dup
    foreign_params.delete('app_id')
    if @service_provider
      ticket = Ticket.create(service_provider: @service_provider, user: user, request_ip: real_ip)
      ticket.save
      return "#{CommonUtils.format_query(params[:redirect_from] || @service_provider.callback_url)}&ticket=#{ticket.par_value}&sign=#{ticket.sign}&#{foreign_params.to_query}"
    else
      return user
    end
  end

  # @notice: set NGINX server config:
  #   server block: proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
  def real_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end
end
