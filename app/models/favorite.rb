class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :effect

  acts_as_taggable_on :tags

  validates :user_id, presence: true
  validates :effect_id, presence: true
end
