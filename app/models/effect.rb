class Effect < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy
  has_many :collection_effects, dependent: :destroy
  has_many :collections, through: :collection_effects
  has_many :news_feeds, dependent: :destroy

  has_many :images, as: :imageable, dependent: :destroy
  has_one :before_image, -> { where(image_type: "before") }, class_name: "Image", as: :imageable, dependent: :destroy
  has_one :after_image, -> { where(image_type: "after") }, class_name: "Image", as: :imageable, dependent: :destroy

  mount_uploader :img, EffectImageUploader

  acts_as_taggable_on :categories, :tasks

  scope :search, ->(query) {
    return all if query.blank?

    query_downcased = "%#{query.downcase}%"
    where('LOWER(name) LIKE ? OR LOWER(description) LIKE ?', query_downcased, query_downcased)
  }

  # ALLOWED_TAGS = %w[моушен-дизайн анимация vfx обработка_фото обработка_видео 3d-графика].freeze

  def average_rating
    avg = ratings.average(:number)
    avg ? avg.to_f.round(2) : 0.0
  end

  def before_image
    images.find_by(image_type: "before")&.file
  end

  def after_image
    images.find_by(image_type: "after")&.file
  end


  def category_list
    categories.pluck(:name)
  end

  def task_list
    tasks.pluck(:name)
  end

  # validate :validate_tags

  private

  # def validate_tags
  #   invalid_tags = tag_list - ALLOWED_TAGS
  #   if invalid_tags.any?
  #     errors.add(:tag_list, "Есть невалидные теги: #{invalid_tags.join(', ')}. Разрешены только: #{ALLOWED_TAGS.join(', ')}")
  #   end
  # end
end
