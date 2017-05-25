class TicketsController < ApplicationController
  include CommonUtils

  def authenticate
    app = ServiceProvider.find_by_app_id(params[:app_id])
    if app == nil
      puts "NO APP"
      render json: {info: 'no application '} and return
    end
    if validate_sign(params[:ticket], params[:sign], app)
      ticket = Ticket.find(aes_decrypt(app.secret_key, params[:ticket]))
      if ticket.blank? || ticket.expired?
        render json: to_response("Invalid ticket")
      else
        render json: to_response("success", ticket.member)
      end
    else
      render json: to_response("Bad request | Invalid parameter(s)")
    end
  end

  private

  def validate_sign(ticket, sign, app)
    sign == Digest::MD5::hexdigest("#{app.app_id}-#{ticket}-#{app.credential}")
  end

  def to_response(msg, user = nil)
    seq = Time.now.to_i #TODO-improve
    code = msg.downcase == 'success' ? 0 : 999
    for_sign = [seq, code, msg].map(&:to_s).join('-') + '-'
    for_sign +=[user.name, user.employee_id, user.email].map(&:to_s).join('-') if user
    signature = Digest::MD5::hexdigest(for_sign)
    res = {seq: seq,
           status: {code: code,
                    msg: msg}
    }
    res.merge!({user: {username: user.name,
                       employee_id: user.employee_id,
                       email: user.email}}) if user
    res.merge ({sign: signature})
  end
end
