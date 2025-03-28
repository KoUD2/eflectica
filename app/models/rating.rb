class Rating < ApplicationRecord
  belongs_to :ratingable, polymorphic: true
  belongs_to :user

  validates :number, inclusion: { in: 1..5 }
  validates :user_id, presence: true
end
