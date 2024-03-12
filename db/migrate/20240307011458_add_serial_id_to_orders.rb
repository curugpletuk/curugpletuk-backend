class AddSerialIdToOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :id
    add_column :orders, :id, :serial, primary_key: true
  end
end
