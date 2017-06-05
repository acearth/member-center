class User < ApplicationRecord
	enum role: {ordinary: 0, admin: 1, inactive: 2, at_risk: 3, resigned: 4}
	attr_accessor :remember_token
	after_create {UserSecurity.create(user: self)}

	has_secure_password


	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def authenticated?(remember_token)
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end

	def admin?
		role == :admin
	end

	class << self
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
					BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end

		def new_token
			SecureRandom.urlsafe_base64
		end
	end

end
