class FavoriteLink < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :url, presence: true
end 