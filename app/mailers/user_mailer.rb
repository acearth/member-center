class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activate.subject
  #
  def activate(user)
    @user = user
    query = {
        email: @user.email,
        activate_token: UserMailer.email_token('activate', @user)
    }
    @link = "#{activate_user_url(user).strip}?#{query.to_query}"
    mail(to: user.email, subject: 'Activate User | Genius Center')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    query = {
        email: @user.email,
        password_reset_token: UserMailer.email_token('password_reset', @user)
    }
    @link ="#{edit_password_resets_url.strip}?#{query.to_query}"
    mail(to: user.email, subject: 'Password Reset | Genius Center')
  end

  def bonjour
    mail(to: 'gc2017@mt2015.com', subject: 'bonjour SALUTE')
  end

  class << self
    def email_token(act, user)
      aes_encrypt(user.credential[0...16], "#{Time.now.to_i}-#{act.to_s}")
    end

    def valid_email_token(act, token, user)
      msg = aes_decrypt(user.credential[0...16], token).split('-')
      return false if msg.size!= 2 || msg.any?(&:nil?)
      msg[1] == act && !expired?(msg[0])
    end

    def expired?(issue_time)
      Time.now.to_i > issue_time.to_i && issue_time.to_i > 30.minutes.ago.to_i
    end
  end
end
