class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.mail['default_from']
  layout 'mailer'
end
