class CreateAccountEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :account_events do |t|
      t.integer :event_type
      t.string :event_token
      t.boolean :finished
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
