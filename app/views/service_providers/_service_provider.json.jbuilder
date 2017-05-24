json.extract! service_provider, :id, :app_id, :auth_level, :credential, :secret_key, :user_id, :description, :created_at, :updated_at
json.url service_provider_url(service_provider, format: :json)
