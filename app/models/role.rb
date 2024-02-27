class Role < ApplicationRecord
  has_many :users, dependent: :delete_all
  
  validates :role_name, presence: true
end
