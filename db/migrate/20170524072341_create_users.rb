class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :emp_id
      t.string :mobile_phone
      t.string :email
      t.string :credential
      t.integer :role
      t.string :password_digest

      t.timestamps
    end
  end
end
