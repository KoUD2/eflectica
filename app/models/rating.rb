class Rating < ApplicationRecord
  belongs_to :ratingable, polymorphic: true
  belongs_to :user
  validates :number, presence: true, inclusion: { in: 1..5 }
end
