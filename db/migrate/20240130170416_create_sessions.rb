class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.string :token
      t.string :device
      t.string :ip_address
      t.string :device_id
      t.datetime :last_active
      t.references :user, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
