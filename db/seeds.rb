# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(
    user_name: 'ace',
    emp_id: 'X1234',
    email: 'sample@worksap.co.jp',
    mobile_phone: '+86 134-5678-9990',
    role: :admin,
    password: 'asdf'
)


User.create(
    user_name: 'arthur',
    emp_id: 'X1235',
    email: 's0@worksap.co.jp',
    mobile_phone: '+89 134-5678-9990',
    role: :ordinary,
    password: 'asdf'
)


ServiceProvider.create(
    app_id: 'sample_app',
    description: 'SAMPLE APP',
    callback_url: 'http://localhost:3000/login_callback',
    credential: SecureRandom.base58(32),
    secret_key: SecureRandom.base58(16),
    user: User.first
)
