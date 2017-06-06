class SessionsController < ApplicationController
  include SessionsHelper
  include CommonUtils

  before_action :set_third_party, only: [:new, :create]

  def new
    redirect_to login_back(current_user) if current_user
  end

  def create
    user = User.find_by_user_name(params[:user_name] || params[:session][:user_name])
    if user && user.valid_role? && user.authenticate(params[:password] || params[:session][:password])
      if user.role == :inactive
        flash[:warning] = 'User not activated, please check your mailbox.'
        redirect_to root_path
      end
      return render json: to_response('success', user) if params[:direct_login] || params[:session][:direct_logint]
      log_in user
      remember user
      redirect_to login_back(user)
    else
      flash[:warning] = I18n.t('wrong_user_or_password') + ", Or, your account is not activated."
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

  def login_params(params)
    params.require(params[:session]).permit(:user_name, :password, :app_id)
  end

  def login_back(member)
    if @service_provider
      ticket = Ticket.create(service_provider: @service_provider, user: member, request_ip: request.remote_ip)
      ticket.save
      return "#{format_query(@service_provider.callback_url)}&ticket=#{ticket.par_value}&sign=#{ticket.sign}"
    else
      return member
    end
  end

  def to_response(msg, user = nil)
    seq = Time.now.to_i #TODO-improve
    code = msg.downcase == 'success' ? 0 : 999
    for_sign = [seq, code, msg].map(&:to_s).join('-') + '-'
    for_sign +=[user.user_name, user.emp_id, user.email].map(&:to_s).join('-') if user
    signature = Digest::MD5::hexdigest(for_sign)
    res = {seq: seq,
           status: {code: code,
                    msg: msg}
    }
    res.merge!({user: {user_name: user.user_name,
                       employee_id: user.emp_id,
                       email: user.email}}) if user
    res.merge ({sign: signature})
  end
end
