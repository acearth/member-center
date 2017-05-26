class ServiceProvider < ApplicationRecord
  belongs_to :user
  enum auth_level: {cookie: 0, password: 1, '2fa' => 2}

  class << self
    def new_secret_key
      SecureRandom.base58(16)
    end
    def new_credential
      SecureRandom.base58(32)
    end
  end
end
