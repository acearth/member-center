class AddUniqueAddRequiredConstraintsToUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_null :users, :role, false
    change_column_null :users, :email, false
    change_column_null :users, :mobile_phone, false
    change_column_null :users, :password_digest, false
    change_column_null :users, :emp_id, false
  end
end
