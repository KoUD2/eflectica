class Question < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  belongs_to :user

  acts_as_taggable_on :tags

  ALLOWED_TAGS = %w[моушен-дизайн анимация vfx обработка_фото обработка_видео 3d-графика].freeze

  validate :validate_tags

  scope :search, -> (query) {
    where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%")
  }

  private

  def validate_tags
    invalid_tags = tag_list - ALLOWED_TAGS
    if invalid_tags.any?
      errors.add(:tag_list, "Есть невалидные теги: #{invalid_tags.join(', ')}. Разрешены только: #{ALLOWED_TAGS.join(', ')}")
    end
  end
end
