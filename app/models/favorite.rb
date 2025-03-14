class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :effect

  scope :search, ->(query) {
  return all if query.blank?

  query_downcased = "%#{query.downcase}%"
  joins(:effect).where('LOWER(effects.name) LIKE ? OR LOWER(effects.description) LIKE ?', query_downcased, query_downcased)
}


  # acts_as_taggable_on :tags

  validates :user_id, presence: true
  validates :effect_id, presence: true
end
