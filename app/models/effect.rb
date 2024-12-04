class Effect < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  has_many :collection_effects, dependent: :destroy
  has_many :collections, through: :collection_effects
  mount_uploader :img, EffectImageUploader

  acts_as_taggable_on :tags

  ALLOWED_TAGS = %w[3д фото видео].freeze

  validate :validate_tags

  private

  def validate_tags
    invalid_tags = tag_list - ALLOWED_TAGS
    if invalid_tags.any?
      errors.add(:tag_list, "Есть невалидные теги: #{invalid_tags.join(', ')}. Разрешены только: #{ALLOWED_TAGS.join(', ')}")
    end
  end
end
