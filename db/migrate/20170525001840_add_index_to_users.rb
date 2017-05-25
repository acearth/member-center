class AddIndexToUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :user_name
  end
end
