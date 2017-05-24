class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.references :service_provider, foreign_key: true
      t.references :user, foreign_key: true
      t.string :request_ip

      t.timestamps
    end
  end
end
