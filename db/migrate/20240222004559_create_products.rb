class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :package_name
      t.integer :price
      t.string :product_type

      t.timestamps
    end
  end
end
