class Product < ApplicationRecord
  enum :product_type, { basic: 0, addon_camp: 1, overnight: 2, river_tracking: 3 }

  validates :package_name, presence: true
  validates :price, presence: true

  def self.get_all_products
    @products = Product.select("id, package_name, price, product_type")
    return { code: 200, status: "OK", data: { product: @products} }
  end
end
