class NewsFeed < ApplicationRecord
  belongs_to :user
  belongs_to :effect
  belongs_to :collection

  validates :user_id, presence: true
  validates :effect_id, presence: true
end
