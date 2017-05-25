class AddIndexToServiceProviders < ActiveRecord::Migration[5.1]
  def change
    # remove_index :service_providers, :app_id
    add_index :service_providers, :app_id, unique: true
  end
end
