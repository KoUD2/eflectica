class NewsFeed < ApplicationRecord
  belongs_to :user
  belongs_to :effect
  belongs_to :collection

  validate :cannot_be_private_collection

  validates :user_id, presence: true
  validates :effect_id, presence: true

  private

  def cannot_be_private_collection
    if collection.status == 'private'
      errors.add(:collection, 'cannot be private')
    end
  end
end
