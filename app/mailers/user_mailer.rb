class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activate.subject
  #
  def activate(user)
    @greeting = "Hi"

    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user, link)
    @greeting = "Hi"
    @link = link
    mail(to: user.email,
         subject: 'Genius Center')
  end

  def bonjour
    mail(to: 'gc2017@mt2015.com',
         subject: 'bonjour SALUTE')
  end
end
