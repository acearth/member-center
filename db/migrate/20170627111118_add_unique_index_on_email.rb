class AddUniqueIndexOnEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :employee_refs, :email, unique: true
  end
end
