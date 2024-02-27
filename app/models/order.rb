require 'veritrans'
require 'base64'

class Order < ApplicationRecord

  after_create :update_token, :send_notification
  
  belongs_to :user
  belongs_to :product

  enum :order_status, { pending: 0, paid: 1, unpaid: 2, canceled: 3, waiting_list: 4 }
  validates :user_id, :product_id, :amount, presence: :true

  


end
