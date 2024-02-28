# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

arr_role = [{ role_name: "Admin" }, { role_name: "Customer" }]
Role.create!(arr_role)

basic = Product.create(package_name: "Basic Package", price: 1000, product_type: 0)
addon_camp = Product.create(package_name: "Add On Camp Package", price: 1000, product_type: 1)
overnight = Product.create(package_name: "Overnight Package", price: 1000, product_type: 2)
river_tracking = Product.create(package_name: "River Tracking Package", price: 1000, product_type: 3)

# basic = Product.create(package_name: "Basic Package", price: 200000, product_type: 0)
# addon_camp = Product.create(package_name: "Add On Camp Package", price: 350000, product_type: 1)
# overnight = Product.create(package_name: "Overnight Package", price: 50000, product_type: 2)
# river_tracking = Product.create(package_name: "River Tracking Package", price: 60000, product_type: 3)
