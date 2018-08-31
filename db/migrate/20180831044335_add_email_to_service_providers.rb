class AddEmailToServiceProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :service_providers, :email, :string
  end
end
