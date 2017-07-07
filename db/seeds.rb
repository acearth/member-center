# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

10.times do |n|
  Faker::Config.locale = 'zh-CN'
  User.create!(user_name: 'name.' + n.to_s,
               email: "example-#{n+1}@worksap.co.jp",
               role: 0,
               credential: SecureRandom.base58(32),
               mobile_phone: Faker::PhoneNumber.cell_phone,
               emp_id: 'TEST-' + Faker::Number.number(10),
               password: 'password')
end


ServiceProvider.create!(app_id: 'sample_app',
                        description: 'SAMPLE APP',
                        callback_url: 'http://localhost:3000/login_callback',
                        credential: SecureRandom.base58(32),
                        secret_key: SecureRandom.base58(16),
                        user: User.first)

