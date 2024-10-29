class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :effect

  validates :user_id, presence: true
  validates :effect_id, presence: true
end
