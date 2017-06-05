class UserSecurity < ApplicationRecord
  belongs_to :user

  before_create :set_otp_key

  def render_otp_key
    "otpauth://totp/GeniusCenter:#{user.user_name}?secret=#{otp_key}&issuer=GeniusCenter"
  end

  def valid_otp?(otp)
    otp == ROTP::TOTP.new(otp_key).now
  end

  class << self
    def valid_otp?(user, otp)
      UserSecurity.find_by_user_id(user.id).valid_otp?(otp)
    end
  end

  private
  # set one-time-password for 2FA, refers to RFC 4226 and RFC 6238.
  def set_otp_key
    self.otp_key = ROTP::Base32.random_base32
  end
end
