class User < ApplicationRecord
  before_save {email.downcase!}
  # validates :mobile_phone, phone: true #SHUT DOWN temporarily
  validates :user_name, format: {with: /\A([a-z0-9]+\.?)*[a-z0-9]+\z/, message: I18n.t('user_name_hint')}, length: {minimum: 3}, on: [:create, :save, :update]
  validates :email, format: {with: /\A\w+@worksap\.co\.jp\z/, message: 'Invalid Email'}, uniqueness: true, on: :create
  validates :password, length: {minimum: 6}, if: :password
  enum role: {ordinary: 0, admin: 1, inactive: 2, at_risk: 3, resigned: 4}
  attr_accessor :remember_token
  after_create {UserSecurity.create(user: self)}
  has_secure_password


  def remember
    @remember_token = User.new_token
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
    _role = role.to_sym
    _role == :admin
  end

  def invalid_role?
    _role = role.to_sym
    _role == :inactive || _role == :resigned
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
