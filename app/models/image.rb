class Image < ApplicationRecord
  attr_accessor :user_email

  before_save :add_metadata_to_image
  mount_uploader :image, ImageUploader
  belongs_to :imageable, polymorphic: true

  def new_attribute
    {
      id: self.id,
      image_url: self.image.url,
      thumbnail_url: self.image.url(:thumbnail)
    }
  end

  private

  def add_metadata_to_image

    return unless image.present? && image.file.present?
    return if user_email.blank?
    Rails.logger.info("User Email in add_metadata_to_image: #{user_email}")
    
    file_path = image.path 
    exif = MiniExiftool.new(file_path)
    if exif['Creator'].present?
      if exif['Creator'] == user_email
        return
      elsif exif['Contributor'] != user_email
        exif['Contributor'] = user_email
      end
    else
      exif['Creator'] = user_email
    end
    exif.save!
  end

end
