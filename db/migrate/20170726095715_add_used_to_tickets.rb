class AddUsedToTickets < ActiveRecord::Migration[5.1]
  def change
    add_column :tickets, :used, :boolean
  end
end
