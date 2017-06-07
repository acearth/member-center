class TicketsController < ApplicationController
  include CommonUtils

  before_action :set_service_proivider
  before_action :ticket_params

  def authenticate
    if valid_sign?(@service_provider.app_id,
                   params[:ticket],
                   @service_provider.credential,
                   params[:sign])
      ticket = Ticket.recover(@service_provider, params[:ticket])
      if ticket.blank? || ticket.expired?
        render json: to_response("Invalid ticket")
      else
        render json: to_response("success", ticket.user)
      end
    else
      render json: to_response("Bad request | Invalid parameter(s)")
    end
  end

  private

  def valid_sign?(*info, got_sign)
    expected = Digest::MD5::hexdigest(info.join('-'))
    return true if expected == got_sign.to_s
    puts 'Sign Validation for:  ' + info.join(' - ')
    puts 'Expected: ' + expected
    puts 'GOT:      ' + got_sign
    false
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

  private
  def ticket_params
    params.require(:app_id)
    params.require(:ticket)
    params.require(:sign)
  end

  def set_service_proivider
    @service_provider = ServiceProvider.find_by_app_id(params[:app_id])
    unless @service_provider
      puts "app_id | SP : #{app_id} | #{@service_provider.id}"
      flash[:warning] = 'No app_id parameter existed.'
      redirect_to login_path
    end
  end

end
