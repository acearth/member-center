class Api::V1::GeniusController < ApplicationController
  skip_forgery_protection
  before_action :set_service_proivider
  USER_DN = 'ou=ldap_users,dc=internal,dc=worksap,dc=com'

  def jwt_user
    secret = ENV['JWT_SECRET']
    json = JWT.decode params[:jwt] || cookies[:jwt_genius], secret, true, {:algorithm => 'HS256'}
    result = {code: 0, user_name: json.first['user_name'], sign: CommonUtils.md5_sign("0-#{json.first['user_name']}-#{@service_provider.secret_key}")}
    render json: result
  rescue => e
    render json: {code: 998, msg: 'unauthorized: ' + e.message}, status: :unauthorized
    # render json: {code: 998, msg: 'invalid jwt token', sign: CommonUtils.md5_sign("998-#{@service_provider.secret_key}")}
  end

  def exist?
    render plain: (User.find_by_user_name(params[:user_name]) && true || false)
  end

  # Params
  #   app_id
  #   user_name
  #   password
  #   sign
  def login
    mandatory_keys = [:app_id, :user_name, :password, :sign]
    if params.slice(*mandatory_keys).values.any?(&:nil?)
      render json: to_response('Some params are lost') and return
    elsif @service_provider.nil?
      render json: to_response('ServiceProvider error') and return
    elsif not CommonUtils.valid_sign?(params[:app_id], params[:user_name], params[:password], @service_provider.credential, params[:sign])
      render json: to_response('Invalid request: parameter error') and return
    end

    user = User.find_by_user_name(params[:user_name])
    if user && user.authenticate(params[:password])
      render json: (user.invalid_role? ? to_response('User needs to be activated') : to_response('success', user))
    elsif user.nil?
      render to_response "User not exist:#{params[:user_name]}"
    else
      render to_response 'Password error'
    end
  end

  # Params
  #   app_id
  #   ticket
  #   sign
  #
  # 1. try cookie first after validation
  # 2. fetch by ITS LDAP
  def authenticate
    mandatory_keys = [:app_id, :ticket, :sign]
    if params.slice(*mandatory_keys).values.any?(&:nil?)
      render json: to_response('Some params are lost') and return
    elsif @service_provider.nil?
      render json: to_response('ServiceProvider error') and return
    elsif not CommonUtils.valid_sign?(@service_provider.app_id, params[:ticket], @service_provider.credential, params[:sign])
      render json: to_response("Bad request: Invalid parameter(s)") and return
    end

    ticket = Ticket.recover(@service_provider, params[:ticket])
    if ticket.blank? || ticket.expired?
      render json: to_response("Invalid ticket")
    else
      ticket.used = true
      ticket.save!
      render json: to_response("success", get_user_from_ticket(ticket))
    end
  end

  private

  def get_user_from_ticket(ticket)
    User.find_by_email(ticket.email) || fetch_ldap_user(ticket.email)
  end

  def to_response(msg, user = nil)
    seq = Time.now.to_i #TODO-improve
    code = msg.downcase == 'success' ? 0 : 999
    for_sign = [seq, code, msg].map(&:to_s).join('-') + '-'
    for_sign +=[user.user_name, user.emp_id, user.email].map(&:to_s).join('-') if user
    signature = CommonUtils.md5_sign(for_sign)
    res = {seq: seq,
           status: {code: code,
                    msg: msg}
    }
    res.merge!({user: {user_name: user.user_name,
                       employee_id: user.emp_id,
                       email: user.email}}) if user
    res.merge!({note: 'This user authenticated by ITS LDAP '}) if user.id.nil?
    res.merge ({sign: signature})
  end

  def set_service_proivider
    @service_provider = ServiceProvider.find_by_app_id(params[:app_id])
  end

  def fetch_ldap_user(email)
    prefix = email.split("@worksap.co.jp").first
    Net::LDAP.new(host: 'ldap-jp01.workslan').open do |server|
      server.auth("uid=#{prefix},ou=ldap_users,dc=internal,dc=worksap,dc=com", password)
      if server.bind
        filter = Net::LDAP::Filter.eq("uid", prefix)
        result = server.search(base: USER_DN, filter: filter)
        # return result.first if server.get_operation_result['code'] == 0
        if server.get_operation_result['code'] == 0
          return User.new(user_name: email.split("@worksap.co.jp").first, ##TODO-confirm: ITS LDAP user confirm
                          emp_id: result.first['employeenumber'],
                          email: email, note: 'This user from ITS LDAP')
        end
      end
    end
  end
end
