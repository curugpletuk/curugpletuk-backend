class OrderMailer < ApplicationMailer
  default from: 'no-reply@gmail.com'
  def confirm_order(order, user)
    @order = order
    @user = user
    @product = Product.find_by_id(order.product_id)
    mail(to: @user.email, subject: "Confirmation Order Ticket")
  end
  # @product = Product.find_by_id(order.product_id)
    # @order, @user, @link = order, user, link
  # def order_success order, user
  #   @product = Product.find_by_id(order.product_id)
  #   @order, @user = order, user
  #   mail(to: @user.email, subject: "Payment Successfully")
  # end
  # def order_cancelled order, user
  #   @order, @user = order, user
  #   mail(to: @user.email, subject: "Payment Failed")
  # end
end
