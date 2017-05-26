class Ticket < ApplicationRecord
  include CommonUtils
  extend CommonUtils

  belongs_to :service_provider
  belongs_to :user

  def par_value
    aes_encrypt(service_provider.secret_key, service_provider.salt+ id.to_s)
  end

  # sign = MD5(ticket.value, credential)
  def sign
    Digest::MD5.hexdigest("#{par_value}-#{service_provider.credential}")
  end

  def expired?
    created_at < 5.minutes.ago
  end

  class << self
    def recover(service_provider, ticket)
      got = aes_decrypt(service_provider.secret_key, ticket)
      find(got.sub(service_provider.salt, ''))
    end
  end
end
