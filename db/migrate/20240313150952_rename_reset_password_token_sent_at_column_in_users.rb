class RenameResetPasswordTokenSentAtColumnInUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :reset_password_token_sent_at, :string
    add_column :users, :reset_password_token_sent_at, :datetime
    remove_column :users, :confirm_token_sent_at, :string
    add_column :users, :confirm_token_sent_at, :datetime
  end    
end
