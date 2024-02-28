class Product < ApplicationRecord
  enum :product_type, { basic: 0, addon_camp: 1, overnight: 2, river_tracking: 3 }

  has_many :orders, dependent: :delete_all

  validates :price, presence: true
  validates :package_name, presence: true

  def self.get_all_products
    @products = Product.select("id, package_name, price, product_type")
    return { code: 200, status: "OK", data: { product: @products} }
  end
end
