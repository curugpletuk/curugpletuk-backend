class Product < ApplicationRecord
  enum :product_type, { basic: 0, addon_camp: 1, overnight: 2, river_tracking: 3, tourism_education: 4, robusta_coffee: 5 }

  has_many :orders, dependent: :delete_all

  validates :price, presence: true
  validates :package_name, presence: true

  def self.get_all_products
    products = Product.select("id, package_name, price, product_type")
    return { code: 200, status: "OK", data: { products: products} }
  end

  def product_attribute 
    @product = Product.find(self.product_id)
    {
      id: self.id,
      package_name: self.package_name,
      product_type: self.product_type,
      price: self.price
    }
  end
end
