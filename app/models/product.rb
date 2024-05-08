class Product < ApplicationRecord
  has_many :orders, dependent: :delete_all
  belongs_to :user

  # has_one :product_image, as: :imageable, class_name: 'Image', dependent: :destroy
  # accepts_nested_attributes_for :product_image, allow_destroy: true

  # validates :product_image, presence: { message: "harus diisi" }
  validates :package_name, presence: { message: "harus diisi" }
  validates :package_name, length: { maximum: 100,  message: "tidak boleh lebih dari 100 karakter"}
  validates :price, presence: { message: "harus diisi" },
                    numericality: { only_integer: true, message: "harus berupa bilangan bulat" }                    
  validates :description, presence: { message: "harus diisi" }
  validates :description, length: { maximum: 500,  message: "tidak boleh lebih dari 500 karakter"}

  def self.get_all_products
    products = Product.select("id, package_name, price, description")
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
    { code: 201, status: "CREATED", message: "Produk telah diubah", data: self.product_attribute }
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
    {
      id: id,
      package_name: package_name,
      price: price,
      description: description,
      # product_image: self.product_image&.image&.url
      # product_image: self.product_image&.image_url  
    }
  end
end
