# TODO-improve: failed to set in different ENV
Sidekiq.configure_server do |config|
  config.redis = {url: 'redis://redis:6379/10'}
end

Sidekiq.configure_client do |config|
  config.redis = {url: 'redis://redis:6379/10'}
end