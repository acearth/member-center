# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:13000/rails/mailers/user_mailer/activate
  def activate
    UserMailer.activate(User.last, '--info--')
  end

  # Preview this email at http://localhost:13000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset(User.last,'--info--')
  end

end
