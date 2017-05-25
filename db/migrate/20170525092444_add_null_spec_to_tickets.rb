class AddNullSpecToTickets < ActiveRecord::Migration[5.1]
  def change
    change_column_null :tickets, :user_id, false
    change_column_null :tickets, :service_provider_id, false
  end
end
