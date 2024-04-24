class Product < ApplicationRecord
  has_many :orders, dependent: :delete_all
  belongs_to :user

  validates :price, presence: true
  validates :package_name, presence: true

  def self.get_all_products
    products = Product.select("id, package_name, price")
    return { code: 200, status: "OK", data: { products: products} }
  end

  def self.create_product(params, current_user)
    product = current_user.products.new(params)
    if product.save
    { code: 201, status: "CREATED", message: "Produk telah ditambahkan", data: product.product_attribute }
    else
    { code: 422, status: "UNPROCESSABLE ENTITY", message: product.errors.full_messages }
    end
  end

  def update_product(params)
    if self.update(params)
    { code: 200, status: "OK", message: "Produk telah diubah", data: self.product_attribute }
    else
    { code: 422, status: "UNPROCESSABLE ENTITY", message: self.errors.full_messages }
    end
  end

  def destroy_product
    if self.destroy
    { code: 200, status: "OK", message: "Produk telah dihapus" }
    else
    { code: 422, status: "UNPROCESSABLE ENTITY", message: self.errors.full_messages }
    end
  end

  def product_attribute 
    # @product = Product.find(self.product_id)
    {
      id: self.id,
      package_name: self.package_name,
      price: self.price
    }
  end
end
