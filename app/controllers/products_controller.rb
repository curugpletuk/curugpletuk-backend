class ProductsController < ApplicationController
  before_action :set_product, only: [:show]
  
  def index
    @product = Product.all
    render json: @product
  end

  def show
    render json: @product
  end

  private
  def set_product
    @product = Product.find(params[:id])
  end
end
