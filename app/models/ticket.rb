class Ticket < ApplicationRecord
  include CommonUtils

  belongs_to :service_provider
  belongs_to :user

  def par_value
    aes_encrypt(service_provider.secret_key, id.to_s)
  end

  # sign = MD5(ticket.value, credential)
  def sign
    Digest::MD5.hexdigest("#{par_value}-#{service_provider.credential}")
  end

  def expired?
    created_at < 5.minutes.ago
  end
end
