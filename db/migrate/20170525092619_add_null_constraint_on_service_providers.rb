class AddNullConstraintOnServiceProviders < ActiveRecord::Migration[5.1]
  def change
    change_column_null :service_providers, :app_id, false
    change_column_null :service_providers, :user_id, false
    change_column_null :service_providers, :credential, false
    change_column_null :service_providers, :secret_key, false
    change_column_null :service_providers, :callback_url, false
  end
end
