class ServiceProvider < ApplicationRecord
  belongs_to :user
  enum auth_level: { cookie: 0, password: 1, '2fa': 2 }
end
