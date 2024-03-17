class OrdersController < ApplicationController
  before_action :authenticate_request!

  def index
    @orders = Order.all
    render json: { code: 200, status: "OK", data: @orders.map { |order| order.order_new_attribute } }, status: :ok
  end
  
  def show
    @order = Order.find(params[:id])
    render json: { code: 200, status: "OK", data: @order.order_new_attribute }, status: :ok
  end

  def check_user_order
    @orders = current_user.orders.all
    render json: @orders.map(&:order_new_attribute), status: :ok
  end
  
  def create
    order = Order.create_orders(order_params, current_user)
    default_response(order)
  end

  private
  def order_params
    params.require(:order).permit(:product_id, :amount, :set_date)
  end

end
