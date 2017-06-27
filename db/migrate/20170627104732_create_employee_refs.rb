class CreateEmployeeRefs < ActiveRecord::Migration[5.1]
  def change
    create_table :employee_refs do |t|
      t.string :emp_id
      t.string :full_name
      t.string :kana
      t.string :email

      t.timestamps
    end
  end
end
