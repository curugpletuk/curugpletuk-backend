class Product < ApplicationRecord
  enum product_type: { basic: 0, addon_camp: 1, overnight: 2, river_tracking: 3 }

  validates :package_name, presence: true
  validates :price, presence: true, numericality: {greater_than: 0}

end
