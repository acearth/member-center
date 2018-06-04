class AddDetailToServiceProvider < ActiveRecord::Migration[5.1]
  def change
    add_column :service_providers, :app_name, :string
    add_column :service_providers, :home_page, :string
    add_column :service_providers, :authentication_type, :integer
    add_column :service_providers, :test_use_only, :boolean, default: false
  end
end
