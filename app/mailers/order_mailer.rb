class OrderMailer < ApplicationMailer
  def confirm_order order, user, link
    @product = Product.find_by_id(order.product_id)
    @order, @user, @link = order, user, link
    mail(to: @user.email, subject: "Confirmation Order")
  end
  def order_success order, user
    @product = Product.find_by_id(order.product_id)
    @order, @user = order, user
    mail(to: @user.email, subject: "Payment Successfully")
  end
  def order_cancelled order, user
    @order, @user = order, user
    mail(to: @user.email, subject: "Payment Failed")
  end
end
