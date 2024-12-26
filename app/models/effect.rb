class Effect < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  has_many :collection_effects, dependent: :destroy
  has_many :collections, through: :collection_effects
  has_many :news_feeds, dependent: :destroy
  mount_uploader :img, EffectImageUploader

  acts_as_taggable_on :tags

  scope :search, ->(query) {
    return all if query.blank?

    query_downcased = "%#{query.downcase}%"
    where('LOWER(name) LIKE ? OR LOWER(description) LIKE ?', query_downcased, query_downcased)
  }

  ALLOWED_TAGS = %w[Моушен-дизайн Анимация VFX Обработка_фото Обработка_видео 3D-графика].freeze

  validate :validate_tags

  private

  def validate_tags
    invalid_tags = tag_list - ALLOWED_TAGS
    if invalid_tags.any?
      errors.add(:tag_list, "Есть невалидные теги: #{invalid_tags.join(', ')}. Разрешены только: #{ALLOWED_TAGS.join(', ')}")
    end
  end
end
