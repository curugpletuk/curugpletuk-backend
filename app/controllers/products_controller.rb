class ProductsController < ApplicationController
  def index
    @products = Product.get_all_products
    default_response4(@products)
  end

  def show
    render json: @products.product_attribute, status: :ok
  end
  
end
