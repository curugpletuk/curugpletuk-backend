class Order < ApplicationRecord

  after_create :send_notification, :send_order_email
  
  belongs_to :user
  belongs_to :product
  
  validates :user_id, :product_id, :amount, presence: :true
  validates :set_date, presence: :true

  def self.create_orders(params, current_user)
    order = current_user.orders.new(params)
    if order.save
      order.send_notification
      order.send_order_email
      return { code: 201, status: "CREATED", message: 'Pesanan berhasil dibuat', data: order.order_new_attribute }
    else
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: order.errors.full_messages }
    end
  end


  def send_order_email
    @product = Product.find_by_id(product_id)
    OrderMailer.confirm_order(self, user).deliver_now
  end

  def order_new_attribute 
    @product = Product.find(self.product_id)
    {
      id: self.id,
      product_type: @product.product_type,
      amount: self.amount,
      user_id: self.user_id,
      set_date: self.set_date,
      created_at: self.created_at,
      updated_at: self.updated_at,
      package_name: @product.package_name,
      total_payment: @product.price * amount
    }
  end

  def send_notification
    product = Product.find(product_id)
    Notification.create({
      subtext: product.package_name,
      title: "Pesanan berhasil dibuat",
      description: "Berhasil membuat pesanan dengan nomor id #{self.id} Silahkan lakukan pembayaran pada loket sesuai dengan nominal yang tertera",
      user_id: self.user_id
    })
  end

  def self.show_all_user_orders(user)
    return [] unless user.present?

    user.orders.order(created_at: :desc).map do |order|
      order.order_new_attribute
    end
  end
end

  # def self.set_order(order_id)
  #   return Order.find_by_id(order_id)
  # end


  #   order = User.new(order_params(params))
  #   if order.save
  #     order.send_order_email
  #     return { code: 201, status: "CREATED", message: 'Pesanan berhasil dibuat', data: order }
  #   else
  #     error_messages = user.errors.messages.transform_values { |v| v.first }
  #     return { code: 422, status: "UNPROCESSABLE ENTITY", message: error_messages }
  #   end
  # end

  # def self.order_params(params)
  #   params.permit(:product_id, :amount, :set_date)
  # end

# def self.show_all_user_orders(user)
  #   return [] unless user.present?

  #   user.orders.select(column_names - ["order_status"]).order(created_at: :desc).map do |order|
  #     order.order_new_attribute
  #   end
  # end

  # def send_order_email
  #   OrderMailer.confirm_order(@order, @user).deliver
  # end


# def self.show_all_user_orders(user)
#   if user.present?
#     new_orders = user.orders.select(column_names - ["order_status"]).order("created_at DESC").map do |order|
#       order.order_new_attribute
#     end
#     return new_orders
#   else
#     return []
#   end
# end

# $gross_amount = Product.price
  # enum :order_status, { pending: 0, paid: 1, unpaid: 2, canceled: 3, waiting_list: 4 }

# Midtrans.config.server_key = "SB-Mid-server-_gAWPBITvZu8hYvc7F5_97tX"
# Midtrans.config.client_key = "SB-Mid-client-wEL9HIkE-TZO7kUe"
# Midtrans.config.api_host = "https://api.sandbox.midtrans.com"


  # def self.notification_checking(transaction_id)
  #   @notification = Order.status(transaction_id)
  #   order_id = @notification.data[:order_id]
  #   @order = find_by_id(order_id)
  #   @user = User.find_by_id(@order.user_id)
  #   $gross_amount = @notification.data[:gross_amount]
  #   self.update_transaction(order_id)
  # end

  # def self.update_transaction(transaction_id)
  #   conditions = {}
  #   conditions[:transaction_id] = transaction_id
  #   if @notification.data[:transaction_status] == "settlement"
  #     product = Product.find_by_id(@order.product_id)
  #     if product.product_type == "product"
  #       order_product_success = product.orders.where("order_status = 1").count
  #       conditions[:order_status] = order_product_success <= product.product_quota ? 1 : 4
  #     else
  #       conditions[:order_status] = 1
  #     end
  #     self.send_notification_order(@order, "settlement")
  #     OrderMailer.order_success(@order, @user).deliver_now
  #   end
  #   if @notification.data[:transaction_status] == "expire" || @notification.data[:transaction_status] == "deny"
  #     conditions[:order_status] = 2
  #     self.send_notification_order(@order, "expire")
  #     OrderMailer.order_cancelled(@order, @user).deliver_now
  #   end
  #   if @notification.data[:transaction_status] == "cancel"
  #     conditions[:order_status] = 3
  #     self.send_notification_order(@order, "cancel")
  #     OrderMailer.order_cancelled(@order, @user).deliver_now
  #   end
  #   @order.update(conditions)
  # end

  # def update_token
  #   @user = User.find_by_id(self.user_id)
  #   @product = Product.find_by_id(self.product_id)
  #   # self.create_token!
  #   create_token!
  #   update(order_token: @result.data[:order_token])
  # end

  # def create_token!
  #   self.params_checking!
  #   @result = Midtrans.create_snap_token(
  #     transaction_details: {
  #       order_id: self.id,
  #       gross_amount: @amount_order,
  #       secure: true
  #     },
  #     item_details: [{
  #       id: self.product_id,
  #       price: @product.price,
  #       quantity: self.amount,
  #       name: @product.package_name,
  #       merchant_name: "Tang's",
  #       url: ""
  #     }],
  #     customer_details: {
  #       first_name: @first_name,
  #       last_name: @last_name,
  #       email: @user.email,
  #       phone: @user.phone_number,
  #     },
  #     enabled_payments: [
  #       "bca_klikbca", "bca_klikpay", "bri_epay", "echannel", 
  #       "permata_va", "bca_va", "bni_va", "bri_va", "other_va", 
  #       "gopay", "indomaret", "danamon_online", "shopeepay", "qris"]
  #   )
  # end

  # def self.cancel_request(order_id)
  #   midtrans_key = Midtrans.config.server_key + ":"

  #   response = HTTParty.post("https://api.sandbox.midtrans.com/v2/" + order_id + "/cancel", {
  #     headers: {
  #       "Authorization" => "Basic " + Base64.encode64(midtrans_key),
  #       "Accept" => "application/json",
  #       "Content-Type" => "application/json"
  #     }
  #   })
  #   return response
  # end

  # def params_checking!
  #   @amount_order = @product.price * self.amount
  #   @user_detail = @user.name
  #   if @user_detail.present?
  #     name_parts = @user_detail.split(" ")
  #     @first_name = name_parts.first
  #     @last_name = name_parts.drop(1).join(" ")
  #   end
  # end

# def self.send_notification_order(order, status)
#   @message = {}
#   @message[:subtext] = @product.package_name
#   %w(settlement expire cancel).each do |s|
#     if status == s
#       self.title_process(s)
#       self.description_process(s, order)
#     end
#   end
#   @message[:user_id] = order.user_id
#   Notification.create(@message)
# end

# private

# def self.title_process order_status
#   @message[:title] = case order_status
#   when "settlement"
#     "Pesanan telah berhasil dibayar"
#   when "expire"
#     "Pesanan telah kadaluarsa"
#   when "cancel"
#     "Pesanan dibatalkan"
#   end
# end

# def self.description_process order_status, order
#   @message[:description] = case order_status
#   when "settlement"
#     "Pesanan dengan nomor id #{order.id} telah berhasil dibayarkan"
#   when "expire"
#     "Pesanan dengan nomor id #{order.id} telah kadaluarsa"
#   when "cancel"
#     "Pesanan dengan nomor id #{order.id} telah dibatalkan"
#   end
# end