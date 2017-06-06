class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activate.subject
  #
  def activate(user, link)
    @user = user
    @link = link
    mail(to: user.email, subject: 'Activate User | Genius Center')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user, link)
    @link = link
    mail(to: user.email, subject: 'Password Reset | Genius Center')
  end

  def bonjour
    mail(to: 'gc2017@mt2015.com', subject: 'bonjour SALUTE')
  end
end
