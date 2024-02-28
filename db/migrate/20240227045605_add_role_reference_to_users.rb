class AddRoleReferenceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :phone_number, :string
    add_reference :users, :role, foreign_key: true
  end
end
