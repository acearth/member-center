class RemoveUserRestrictOnTickets < ActiveRecord::Migration[5.2]
  def change
    remove_reference :tickets, :user, foreign_key: true
    add_column :tickets, :user_id, :integer
  end
end
