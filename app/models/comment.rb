class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :effect 
  # belongs_to :rating, optional: true
  has_many :likes, as: :likeable, dependent: :destroy
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy
  has_one :rating, as: :ratingable, dependent: :destroy

  accepts_nested_attributes_for :rating
  
  validates :body, presence: true

  # delegate :number, to: :rating, prefix: true
end
