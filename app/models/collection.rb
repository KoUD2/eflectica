class Collection < ApplicationRecord
  belongs_to :user
  has_many :images, as: :imageable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  has_many :collection_effects, dependent: :destroy
  has_many :sub_collections, dependent: :destroy
  has_many :effects, through: :collection_effects
  has_many :collection_links
  has_many :links, through: :collection_links
  has_many :collection_images, dependent: :destroy
  has_many :images, through: :collection_images
  has_many :news_feeds

  validates :status, inclusion: { in: ['public', 'private'] }

  # acts_as_taggable_on :tags

  # ALLOWED_TAGS = %w[моушен-дизайн анимация vfx обработка_фото обработка_видео 3d-графика].freeze

  # validate :validate_tags

  private

  # def validate_tags
  #   invalid_tags = tag_list - ALLOWED_TAGS
  #   if invalid_tags.any?
  #     errors.add(:tag_list, "Есть невалидные теги: #{invalid_tags.join(', ')}. Разрешены только: #{ALLOWED_TAGS.join(', ')}")
  #   end
  # end
end
