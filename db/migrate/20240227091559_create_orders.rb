class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :amount
      t.integer :order_status
      t.string :order_token
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
