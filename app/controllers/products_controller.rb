class ProductsController < ApplicationController
  before_action :authenticate_request!, except: %i[index show]
  before_action :authorize_admin, except: %i[index show]

  def index
    @products = Product.get_all_products
    default_response4(@products)
  end

  def show
    product = Product.find(params[:id])
    render json: { code: 200, status: "OK", data: product.product_attribute }, status: :ok
  end
  
  def create
    product = Product.create_product(product_params, current_user)
    default_response(product)
  end

  def update
    product = Product.find(params[:id])
    response = product.update_product(product_params)
    default_response(response)
  end

  def destroy
    product = Product.find(params[:id])
    response = product.destroy_product
    default_response(response)
  end

  private

  def product_params
    params.require(:product).permit(:package_name, :price)
  end
end