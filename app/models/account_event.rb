class AccountEvent < ApplicationRecord
  belongs_to :user
  enum event_type: {password_reset: 0, otp_key_reset: 1, activate_user: 2}
  before_create :init_event

  def expired?
    self.created_at < 30.minutes.ago && self.created_at > Time.now
  end

  private
  def init_event
    self.event_token = SecureRandom.base58(60)
    self.finished = false
  end
end

