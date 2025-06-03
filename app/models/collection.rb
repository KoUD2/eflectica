class Collection < ApplicationRecord
  belongs_to :user
  has_many :images, as: :imageable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  has_many :collection_effects, dependent: :destroy
  has_many :sub_collections, dependent: :destroy
  has_many :subscribers, through: :sub_collections, source: :user
  has_many :effects, through: :collection_effects
  has_many :collection_links, dependent: :destroy
  has_many :links, through: :collection_links
  has_many :collection_images, dependent: :destroy
  has_many :images, through: :collection_images
  has_many :news_feeds, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: %w[public private], message: "%{value} недопустим" }
end
