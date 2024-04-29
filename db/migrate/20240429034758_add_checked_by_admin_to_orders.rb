class AddCheckedByAdminToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :checked_by_admin, :boolean, default: false
  end
end
