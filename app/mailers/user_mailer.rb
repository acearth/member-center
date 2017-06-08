class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activate.subject
  #
  def activate(user,link_without_query)
    @user = user
    query = {
        email: @user.email,
        activate_token: CommonUtils.email_token('activate', @user)
    }
    @link = "#{link_without_query.strip}?#{query.to_query}"
    mail(to: user.email, subject: 'Activate User | Genius Center')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user, link_without_query)
    @user = user
    query = {
        email: @user.email,
        password_reset_token: CommonUtils.email_token('password_reset', @user)
    }
    @link ="#{link_without_query.strip}?#{query.to_query}"
    mail(to: user.email, subject: 'Password Reset | Genius Center')
  end

  def bonjour
    mail(to: 'gc2017@mt2015.com', subject: 'bonjour SALUTE')
  end
end
