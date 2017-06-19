class SessionsController < ApplicationController
  include SessionsHelper

  before_action :set_third_party, only: [:new, :create]

  def new
    redirect_to login_back(current_user) and return if current_user
    render layout: false
  end

  def create
    info = params.require(:session).permit(:user_name, :password, :app_id)
    user = User.find_by_user_name(info[:user_name])
    if user && user.authenticate(info[:password])
      if  !user.invalid_role? || user.user_name.start_with?('test')
        log_in user
        remember user
        redirect_to login_back(user)
      else
        flash[:warning] = 'User not activated'
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
      render status: 406 unless @service_provider
    end
  end

  def login_back(member)
    if @service_provider
      ticket = Ticket.create(service_provider: @service_provider, user: member, request_ip: request.remote_ip + ' | ' + request.referer)
      ticket.save
      return "#{CommonUtils.format_query(@service_provider.callback_url)}&ticket=#{ticket.par_value}&sign=#{ticket.sign}"
    else
      return member
    end
  end
end
