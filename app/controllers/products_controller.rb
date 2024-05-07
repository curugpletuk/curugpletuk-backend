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
    # params.permit(:package_name, :price, :description, product_image: [:image])
    params.permit(:package_name, :price, :description)
  end


end


  # def create
  #   product = current_user.products.new(product_params)
  #   if product.save
  #     render json: { code: 201, status: "CREATED", data: product.product_attribute }, status: :created
  #   else
  #     render json: { code: 422, status: "UNPROCESSABLE ENTITY", message: product.errors.full_messages }, status: :unprocessable_entity
  #   end
  # end

  # def update
  #   product = Product.find(params[:id])
  #   if product.update(product_params)
  #     render json: { code: 200, status: "OK", data: product.product_attribute }, status: :ok
  #   else
  #     render json: { code: 422, status: "UNPROCESSABLE ENTITY", message: product.errors.full_messages }, status: :unprocessable_entity
  #   end
  # end

  # def product_params
  #   params.require(:product).permit(:package_name, :price, :description)
  # end

  # def product_params
  #   params.require(:product).permit(:package_name, :price, :description)
  # end

  # def image
  #   params.permit(:image)
  # end