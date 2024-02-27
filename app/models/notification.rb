class Notification < ApplicationRecord
  belongs_to :user

  validates :subtext, :title, :description, presence: true 
end
