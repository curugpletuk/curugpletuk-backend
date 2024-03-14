class OrdersController < ApplicationController
  before_action :authenticate_request!
  before_action :set_order, only: [:show]

  def index
    @orders = current_user.orders.all
    render json: @orders.map(&:order_new_attribute), status: :ok
  end

  def show
    render json: @order.order_new_attribute, status: :ok
  end

  def create
    order = Order.create_orders(order_params, current_user)
    default_response(order)
  end

  private
    def set_order
      @order = current_user.orders.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:product_id, :amount, :set_date)
    end

end
