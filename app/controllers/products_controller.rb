class ProductsController < ApplicationController
  # before_action :set_product, only: [:show]
  
  def index
    @products = Product.get_all_products
    default_response4(@products)
  end

  def show
    render json: @products.product_attribute, status: :ok
  end
  
  # def index
  #   @product = Product.all
  #   render json: @product
  # end

  # def show
  #   render json: @product
  # end

  # private
  # def set_product
  #   @product = Product.find(params[:id])
  # end
end
