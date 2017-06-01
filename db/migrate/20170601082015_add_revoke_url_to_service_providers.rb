class AddRevokeUrlToServiceProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :service_providers, :revoke_url, :string
  end
end
