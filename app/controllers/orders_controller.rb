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


# MIDTRANS_BASE_URL = 'https://app.sandbox.midtrans.com/snap/v3/redirection/'
# def create
#   user_id = params[:user_id]
#   @user = User.find_by(id: user_id)
#   if @user.nil?
#     render json: { code: 404, status: "NOT_FOUND", message: "User tidak ditemukan" }
#     return
#   end

#   @order = Order.new(order_params.merge(order_status: 0, user_id: @user.id))
#   if @order.save
#     if @order.order_token.present?
#       result = { order: @order, redirect_url: MIDTRANS_BASE_URL + @order.order_token }
#       OrderMailer.confirm_order(@order, @user, result).deliver
#       render json: { code: 201, status: "CREATED", message: "Pesanan berhasil dibuat, silakan lakukan pembayaran!", data: result }
#     else
#       render json: { code: 500, status: "INTERNAL_SERVER_ERROR", message: "Gagal membuat pesanan, token pembayaran tidak tersedia" }
#     end
#   else
#     render json: { code: 400, status: "BAD_REQUEST", message: @order.errors.full_messages[0] }
#   end
# end


# def index 
#   orders = Order.show_all_user_orders(current_user)
#   if orders.any?
#     render json: { code: 200, status: "OK", data: orders }
#   else
#     render json: { code: 404, status: "NOT_FOUND", message: "Belum ada pesanan yang dibuat!" }
#   end
# end



# def show 
#   render json: { code: 200, status: "OK", data: { order: @order.order_new_attribute }}
# end

# def notification_handler
#   @data = JSON.parse(request.body.read)
#   Order.notification_checking(@data['transaction_id'])
#   render json: { status: "OK" }, status: :ok
# end

# def cancel 
#   response = Order.cancel_request(params[:order_id])
#   hash_response = response["status_code"] == "200" ? { code: 200, status: "OK", message: "Pesanan berhasil dibatalkan" } :
#                                                     { code: 400, status: "BAD_REQUEST", message: "Pesanan tidak dapat dibatalkan atau sudah dibatalkan!" }
#   render json: hash_response
# end

# private

# def set_order
#   @order = Order.set_order(params[:id])
#   return render json: { code: 404, status: "NOT_FOUND", message: "Pesanan tidak ditemukan!"} if @order.blank?
# end

# def order_params
#   params.require(:order).permit(:product_id, :amount, :set_date)
# end

# def check_transaction
#   if @order.transaction_id.blank? && @order.update(order_status: 3)
#     return default_response({ code: 200, status: "OK", message: "Pesanan berhasil dibatalkan"})
#   end
# end

  # def index 
  #   orders = @user.show_all_user_orders
  #   return render json: { code: 200, status: "OK", data: orders} if orders
  #   render json: { code: 404, status: "NOT_FOUND", message: "Belum ada pesanan yang dibuat!"}
  # end

  # def create
  #   user_id = params[:user_id]
  #   @user = User.find_by(params[:id])
  #   @order = Order.create(orders_params.merge(id: "ORDER-" + Time.now.to_i.to_s , order_status: 0, user_id: @user.id))
    
  #   if @order.valid?
  #     if @order.order_token.present?
  #       result = { order: @order, redirect_url: MIDTRANS_BASE_URL + @order.order_token }
  #       OrderMailer.confirm_order(@order, @user, result).deliver_now
  #       render json: { code: 201, status: "CREATED", message: "Pesanan berhasil dibuat, silakan lakukan pembayaran!", data: result }
  #     else
  #       render json: { code: 500, status: "INTERNAL_SERVER_ERROR", message: "Gagal membuat pesanan, token pembayaran tidak tersedia" }
  #     end
  #   else
  #     render json: { code: 400, status: "BAD_REQUEST", message: @order.errors.full_messages[0] }
  #   end
  # end

  #   def create
  #   user_id = params[:user_id]
  #   @user = User.find_by(params[:id])
  #   @order = Order.create(orders_params.merge(id: "ORDER-" + Time.now.to_i.to_s , order_status: 0, user_id: @user.id))
  #   if @order.valid?
  #     result = { order: @order, redirect_url: MIDTRANS_BASE_URL + @order.order_token }
  #     OrderMailer.confirm_order(@order, @user, result).deliver_now
  #     render json: { code: 201, status: "CREATED", message: "Pesanan berhasil dibuat, silakan lakukan pembayaran!", data: result }
  #   else
  #     render json: { code: 400, status: "BAD_REQUEST", message: @order.errors.full_messages[0] }
  #   end
  # end