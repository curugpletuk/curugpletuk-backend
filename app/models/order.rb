class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :user_id, presence: { message: "harus diisi" }
  validates :product_id, :amount, presence: { message: "harus diisi" }, numericality: { only_integer: true, message: "harus berupa bilangan bulat" }
  validates :set_date, presence: { message: "harus diisi" }
  validate :set_date_format

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
      amount: self.amount,
      user_id: self.user_id,
      name: user.name,
      set_date: self.set_date,
      created_at: self.created_at,
      updated_at: self.updated_at,
      package_name: @product.package_name,
      total_payment: @product.price * amount,
      is_checked: self.checked_by_admin
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

    user.orders.order(created_at: :desc).map(&:order_new_attributes)
  end

  def set_date_format
    return if set_date.blank?
    
    begin
      DateTime.strptime(set_date.to_s, '%Y-%m-%d %H:%M')
    rescue ArgumentError
      errors.add(:set_date, "set date tidak sesuai format")
    end
  end

  # def set_date_format
  #   return if set_date.blank? 

  #   format = "%Y-%m-%d %H:%M"
  #   DateTime.strptime(set_date.to_s, format)
  # rescue ArgumentError
  #   errors.add(:set_date, "harus sesuai format (YYYY-MM-DD HH:MM)")
  # end

  def self.to_csv(start_date, end_date)
    orders = where(created_at: start_date.beginning_of_month..end_date.end_of_month)
    CSV.generate(headers: true) do |csv|
      csv << ['Order ID', 'Amount'] # Header kolom CSV
      orders.each do |order|
        csv << [order.id, order.amount] # Data order
      end
    end
  end
end