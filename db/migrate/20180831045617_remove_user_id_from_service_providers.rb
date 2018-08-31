class RemoveUserIdFromServiceProviders < ActiveRecord::Migration[5.2]
  def change
    remove_column :service_providers, :user_id, :integer
  end
end
