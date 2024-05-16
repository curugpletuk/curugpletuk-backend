class ProductsController < ApplicationController
  before_action :authenticate_request!, except: %i[index show]
  before_action :authorize_admin, except: %i[index show]

  def index
    @products = Product.get_all_products
    default_response4(@products)
  end

  def show
    begin
      product = Product.find(params[:id])
      render json: { code: 200, status: "OK", data: product.product_attribute }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { code: 404, status: "NOT FOUND", message: "Produk tidak ditemukan" }, status: :not_found
    end
  end

  def create
    product = Product.create_product(product_params, image_params, current_user)
    default_response(product)
  end

  def update
    product = Product.find(params[:id])
    response = product.update_product(product_params, image_params)
    default_response(response)
  end

  def destroy_image
    begin
      product = Product.find(params[:id])
      response = product.delete_image
      default_response(response)
    rescue ActiveRecord::RecordNotFound
      render json: { code: 404, status: "NOT FOUND", message: "Produk tidak ditemukan" }, status: :not_found
    end
  end

  def destroy
    begin
      product = Product.find(params[:id])
      response = product.destroy_product
      default_response(response)
    rescue ActiveRecord::RecordNotFound
      render json: { code: 404, status: "NOT FOUND", message: "Produk tidak ditemukan" }, status: :not_found
    end
  end

  private

  def product_params
    params.permit(:package_name, :price, :description)
  end

  def image_params
    params.permit(:image) 
  end
end
