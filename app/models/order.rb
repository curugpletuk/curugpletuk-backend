class Order < ApplicationRecord
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