class CreateUserSecurities < ActiveRecord::Migration[5.1]
  def change
    create_table :user_securities do |t|
      t.references :user, foreign_key: true
      t.string :otp_key

      t.timestamps
    end
  end
end
