class Asset < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable
  has_many :ratings, as: :ratingable
end
