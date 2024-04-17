class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, null: false, foreign_key: true
    remove_column :products, :product_type, :integer
  end
end
