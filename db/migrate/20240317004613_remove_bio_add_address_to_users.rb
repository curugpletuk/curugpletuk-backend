class RemoveBioAddAddressToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :bio, :string
    add_column :users, :address, :string
  end
end
