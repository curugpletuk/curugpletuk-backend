class Image < ApplicationRecord
  # attr_accessor :user_email
  mount_uploader :image, ImageUploader
  belongs_to :imageable, polymorphic: true

  def new_attribute
    {
      id: self.id,
      image_url: self.image.url,
      thumbnail_url: self.image.url(:thumbnail)
    }
  end

end
