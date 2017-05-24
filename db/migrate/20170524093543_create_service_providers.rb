class CreateServiceProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :service_providers do |t|
      t.string :app_id
      t.integer :auth_level
      t.string :credential
      t.string :secret_key
      t.references :user, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
