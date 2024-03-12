class DeleteOrderStatusOnOrder < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :order_status, :integer
  end
end
