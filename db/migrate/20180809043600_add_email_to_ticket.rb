class AddEmailToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :email, :string
  end
end
