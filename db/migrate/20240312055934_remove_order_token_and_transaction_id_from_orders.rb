class RemoveOrderTokenAndTransactionIdFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :order_token, :string
    remove_column :orders, :transaction_id, :string
  end
end
