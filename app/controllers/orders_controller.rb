class OrdersController < ApplicationController
  before_action :authenticate_request!
  before_action :authorize_admin, only: %i[index show checked_order]
  before_action :authorize_customer, only: %i[create]

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
    render json: { code: 200, status: "OK", data: @orders.map(&:order_new_attribute)}, status: :ok
  end
  
  def create
    order = Order.create_orders(order_params, current_user)
    default_response(order)
  end

  def checked_order
    @order = Order.find(params[:id])
    if @order.update(checked_by_admin: true)
      render json: { code: 200, status: "OK", data: @order.order_new_attribute }, status: :ok
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def order_chart
    order_data = Order.group_by_month(:created_at, format: "%b %Y").count
    render json: { code: 200, status: "OK", data: order_data }, status: :ok
  end

  def download
    start_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
    end_date = start_date.end_of_month
  
    orders = Order.to_csv(start_date, end_date) # Memanggil to_csv dengan menyertakan start_date dan end_date
    
    respond_to do |format|
      format.csv do
        send_data orders, filename: "orders-#{start_date.strftime('%Y-%m')}.csv"
      end
    end
  end

  private
  def order_params
    params.require(:order).permit(:product_id, :amount, :set_date)
  end

end
