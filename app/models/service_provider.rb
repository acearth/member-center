class ServiceProvider < ApplicationRecord
  enum auth_level: {cookie: 0, password: 1, '2fa' => 2}
  before_save :keep_test_tag

  class << self
    def new_secret_key
      SecureRandom.base58(16)
    end
    def new_credential
      SecureRandom.base58(32)
    end
  end

  private

  def keep_test_tag
    if test_use_only
      self.salt = 'test use only'
    end
  end
end
