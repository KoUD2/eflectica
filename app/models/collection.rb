class Collection < ApplicationRecord
  belongs_to :asset
  belongs_to :user
  has_many :ratings, as: :ratingable
end
