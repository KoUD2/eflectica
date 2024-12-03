class Collection < ApplicationRecord
  belongs_to :user
  has_many :ratings, as: :ratingable, dependent: :destroy
  has_many :collection_effects, dependent: :destroy
  has_many :sub_collections, dependent: :destroy
  has_many :effects, through: :collection_effects

  acts_as_taggable_on :tags
end
