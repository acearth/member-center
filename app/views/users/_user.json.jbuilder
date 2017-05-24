json.extract! user, :id, :user_name, :emp_id, :mobile_phone, :email, :credential, :role, :password_digest, :created_at, :updated_at
json.url user_url(user, format: :json)
