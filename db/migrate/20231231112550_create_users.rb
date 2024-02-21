class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :bio
      t.string :password_digest
      t.boolean :email_confirmed, :default => false
      t.string :confirm_token
      t.string :confirm_token_sent_at
      t.string :reset_password_token
      t.string :reset_password_token_sent_at

      t.timestamps
    end
  end
end
