class AddSaltToServiceProviders < ActiveRecord::Migration[5.1]
  def change
    add_column :service_providers, :salt, :string
  end
end
