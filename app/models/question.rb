class Question < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  belongs_to :user

  acts_as_taggable_on :tags
end
