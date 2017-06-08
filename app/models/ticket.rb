class Ticket < ApplicationRecord
  belongs_to :service_provider
  belongs_to :user

  def par_value
    CommonUtils.aes_encrypt(service_provider.secret_key, service_provider.salt.to_s + id.to_s)
  end

  # sign = MD5(ticket.value, credential)
  def sign
    CommonUtils.md5_sign(par_value, service_provider.credential)
  end

  def expired?
    created_at < 5.minutes.ago
  end

  class << self
    def recover(service_provider, ticket)
      got = CommonUtils.aes_decrypt(service_provider.secret_key, ticket)
      find(got.sub(service_provider.salt, ''))
    end
  end
end
