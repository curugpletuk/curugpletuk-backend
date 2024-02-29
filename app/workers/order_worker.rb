require 'sidekiq-scheduler'

class OrderWorker
  include Sidekiq::Worker
  def perform #=> you can write anything based on your action like 'send_email' or 'newslatter' etc ...
    puts "Updating Expired Order"
    Order.where("order_status = 0").map do |order|
      if Time.now > (order.created_at + 1.day)
        order.update(order_status: 2)
      end
    end
  end
end