class SessionsController < ApplicationController

  USER_DN = 'ou=ldap_users,dc=internal,dc=worksap,dc=com'
  include SessionsHelper

  before_action :set_third_party, only: [:new, :create]

  def new
    redirect_to login_back(current_user.email) and return if current_user
    @service_provider = ServiceProvider.find_by_app_id(params[:app_id])
    render layout: false
  end

  def create
    info = params.require(:session).permit(:login, :password, :remember_me, :app_id)
    if info[:login].include?('@')
      if ldap_user = authenticate_and_fetch(info[:login], info[:password])
        its_user(ldap_user, info[:remember_me])
        redirect_to login_back(ldap_user[:mail].first)
      else
        flash[:error] = 'ITS LDAP email / password wrong!  Reset password on http://reg.internal.worksap.com if you forgot it'
        redirect_to login_path
      end
    else
      user = User.find_by_user_name(info[:login])
      if user && user.authenticate(info[:password])
        if !user.invalid_role? || user.user_name.start_with?('test')
          log_in user
          remember user if info[:remember_me]
          redirect_to login_back(user.email)
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
  end

  ### ONLY works for worksap user
  def authenticate_and_fetch(email, password)
    prefix = email.split('@worksap.co.jp').first
    # NOTE: use SSH tunnel to forward request
    Net::LDAP.new(host: ENV['ITS_LDAP_HOST'], port: ENV['ITS_LDAP_PORT']).open do |server|
      server.auth("uid=#{prefix},ou=ldap_users,dc=internal,dc=worksap,dc=com", password)
      if server.bind
        filter = Net::LDAP::Filter.eq("uid", prefix)
        result = server.search(base: USER_DN, filter: filter)
        return result.first if server.get_operation_result['code'] == 0
      end
    end
    false
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


  def login_back(email)
    foreign_params = request.query_parameters.dup
    foreign_params.delete('app_id')
    if @service_provider
      ticket = Ticket.create(service_provider: @service_provider, email: email, request_ip: real_ip)
      ticket.save
      return params[:redirect_from] if params[:redirect_from]
      the_url = "#{CommonUtils.format_query(@service_provider.callback_url)}&ticket=#{ticket.par_value}&sign=#{ticket.sign}"
      the_url += "&#{foreign_params.to_query}" if foreign_params
      return the_url
    else
      return root_path
    end
  end

  # @notice: set NGINX server config:
  #   server block: proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
  def real_ip
    request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
  end
end
