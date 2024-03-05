require 'veritrans'
require 'base64'

# Midtrans.config.server_key = Rails.application.credentials.midtrans_sandbox.server_key
# Midtrans.config.client_key = Rails.application.credentials.midtrans_sandbox.client_key
# Midtrans.config.api_host = Rails.application.credentials.midtrans_sandbox.api_host

Midtrans.config.server_key = "SB-Mid-server-_gAWPBITvZu8hYvc7F5_97tX"
Midtrans.config.client_key = "SB-Mid-client-wEL9HIkE-TZO7kUe"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"

class Order < ApplicationRecord

  after_create :update_token, :send_notification
  
  belongs_to :user
  belongs_to :product
  # $gross_amount = Product.price
  enum :order_status, { pending: 0, paid: 1, unpaid: 2, canceled: 3, waiting_list: 4 }
  validates :user_id, :product_id, :amount, presence: :true
  validates :set_date, presence: :true
  

  def self.notification_checking(transaction_id)
    @notification = Midtrans.status(transaction_id)
    order_id = @notification.data[:order_id]
    @order = find_by_id(order_id)
    @user = User.find_by_id(@order.user_id)
    $gross_amount = @notification.data[:gross_amount]
    self.update_transaction(order_id)
  end

  def self.update_transaction(transaction_id)
    conditions = {}
    conditions[:transaction_id] = transaction_id
    if @notification.data[:transaction_status] == "settlement"
      product = Product.find_by_id(@order.product_id)
      if product.product_type == "product"
        order_product_success = product.orders.where("order_status = 1").count
        conditions[:order_status] = order_product_success <= product.product_quota ? 1 : 4
      else
        conditions[:order_status] = 1
      end
      self.send_notification_order(@order, "settlement")
      OrderMailer.order_success(@order, @user).deliver_now
    end
    if @notification.data[:transaction_status] == "expire" || @notification.data[:transaction_status] == "deny"
      conditions[:order_status] = 2
      self.send_notification_order(@order, "expire")
      OrderMailer.order_cancelled(@order, @user).deliver_now
    end
    if @notification.data[:transaction_status] == "cancel"
      conditions[:order_status] = 3
      self.send_notification_order(@order, "cancel")
      OrderMailer.order_cancelled(@order, @user).deliver_now
    end
    @order.update(conditions)
  end

  def update_token
    @user = User.find_by_id(self.user_id)
    @product = Product.find_by_id(self.product_id)
    # self.create_token!
    create_token!
    update(order_token: @result.data[:order_token])
  end

  def create_token!
    self.params_checking!
    @result = Midtrans.create_snap_token(
      transaction_details: {
        order_id: self.id,
        gross_amount: @amount_order,
        secure: true
      },
      item_details: [{
        id: self.product_id,
        price: @price,
        quantity: self.amount,
        name: @product.package_name,
        merchant_name: "Tang's",
        url: ""
      }],
      customer_details: {
        first_name: @first_name,
        last_name: @last_name,
        email: @user.email,
        phone: @user.phone_number,
      },
      enabled_payments: [
        "bca_klikbca", "bca_klikpay", "bri_epay", "echannel", 
        "permata_va", "bca_va", "bni_va", "bri_va", "other_va", 
        "gopay", "indomaret", "danamon_online", "shopeepay", "qris"]
    )
  end

  def self.cancel_request(order_id)
    midtrans_key = Midtrans.config.server_key + ":"

    response = HTTParty.post("https://api.sandbox.midtrans.com/v2/" + order_id + "/cancel", {
      headers: {
        "Authorization" => "Basic " + Base64.encode64(midtrans_key),
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      }
    })
    return response
  end

  def params_checking!
    # if self.product_type == "product"
    #   @price, @amount_order = @product.price.to_i, @product.price.to_i
    # else
    #   @price, @amount_order = 1000, (self.amount.to_i * 1000)
    # end
    @amount_order = self.amount
    @user_detail = @user.name
    name = @user_detail.name.split(" ")
    arr = name.count()
    @first_name, @last_name = name[0], name[1..arr-1].join(" ")
  end

  def self.set_order(order_id)
    return Order.find_by_id(order_id)
  end

  # def self.create_params_checking params={} 
  #   product_types = ["product", "point"]
  #   res = {}
  #   if !product_types.include?(params[:product_type])
  #     res[:error] = { code: 400, status: "BAD_REQUEST", message: "Jenis product tidak ditemukan!" }
  #   end
  #   if params[:product_type] == "product" && params[:amount].to_i > 1
  #     res[:error] = { code: 400, status: "BAD_REQUEST", message: "Kamu hanya bisa membeli satu product!"}
  #   end
  #   if params[:amount].to_i <= 0
  #     res[:error] = { code: 400, status: "BAD_REQUEST", message: "Jumlah harus lebih besar dari 0"}
  #   end
  #   if params[:product_type] == "point" && params[:amount].to_i < 10 
  #     res[:error] = { code: 400, status: "BAD_REQUEST", message: "Jumlah pembelian minimum adalah 10 poin"}
  #   end
  #   return res
  # end

  def order_new_attribute 
    @product = Product.find(self.product_id)
    {
      id: self.id,
      product_type: @product.product_type,
      amount: self.amount,
      user_id: self.user_id,
      set_date: self.set_date,
      order_status: self.order_status,
      created_at: self.created_at,
      updated_at: self.updated_at,
      order_token: self.order_token,
      transaction_id: self.transaction_id,
      package_name: @product.package_name,
      total_payment: @product.product_type == "product" ? (@product.product_price * amount) : (@product.point_price * amount)
    }
  end

  def send_notification
    Notification.create({
      subtext: @product.package_name,
      title: "Pesanan berhasil dibuat",
      description: "Berhasil membuat pesanan dengan nomor id #{self.id} Silahkan lakukan pembayaran sesuai dengan nominal yang diminta",
      user_id: self.user_id
    })
  end

  def self.send_notification_order(order, status)
    @message = {}
    @message[:subtext] = @product.package_name
    %w(settlement expire cancel).each do |s|
      if status == s
        self.title_process(s)
        self.description_process(s, order)
      end
    end
    @message[:user_id] = order.user_id
    Notification.create(@message)
  end

  private

  def self.title_process order_status
    @message[:title] = case order_status
    when "settlement"
      "Pesanan telah berhasil dibayar"
    when "expire"
      "Pesanan telah kadaluarsa"
    when "cancel"
      "Pesanan dibatalkan"
    end
  end

  def self.description_process order_status, order
    @message[:description] = case order_status
    when "settlement"
      "Pesanan dengan nomor id #{order.id} telah berhasil dibayarkan"
    when "expire"
      "Pesanan dengan nomor id #{order.id} telah kadaluarsa"
    when "cancel"
      "Pesanan dengan nomor id #{order.id} telah dibatalkan"
    end
  end
end
