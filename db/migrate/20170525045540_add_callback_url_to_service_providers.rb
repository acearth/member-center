class AddCallbackUrlToServiceProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :service_providers, :callback_url, :string
  end
end
