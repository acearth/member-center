require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GeniusCenter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Configuration for sending mail
    config.action_mailer.default_url_options = { :host => "genius.internal.worksap.com" }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        
        address: ENV['SMTP_HOST'],
        port: ENV['SMTP_PORT'],
        user_name: ENV['SMTP_USER_NAME'],
        password: ENV['SMTP_PASSWORD'],
        authentication: 'plain',
        enable_starttls_auto: true
    }

    config.active_job.queue_adapter = :sidekiq
    # 在使用 Ajax 处理的表单中添加真伪令牌
    config.action_view.embed_authenticity_token_in_remote_forms = true

    config.cache_store = :redis_store, "redis://localhost:6379/0/cache", {expires_in: 90.minutes}

    config.ldap = config_for(:ldap)
  end
end
