class Question < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :ratings, as: :ratingable, dependent: :destroy

  acts_as_taggable_on :categories, :tasks

  has_many :images, as: :imageable, dependent: :destroy
  has_one :before_image, -> { where(image_type: "before") }, class_name: "Image", as: :imageable, dependent: :destroy
  has_one :after_image, -> { where(image_type: "after") }, class_name: "Image", as: :imageable, dependent: :destroy
  has_one :description_image, -> { where(image_type: "description") }, class_name: "Image", as: :imageable, dependent: :destroy


  belongs_to :user



  # ALLOWED_TAGS = %w[моушен-дизайн анимация vfx обработка_фото обработка_видео 3d-графика].freeze

  # validate :validate_tags

  scope :search, -> (query) {
    where("title LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%")
  }

  def before_image
    images.find_by(image_type: "before")
  end
  
  def after_image
    images.find_by(image_type: "after")
  end
  
  def description_image
    images.find_by(image_type: "description")
  end  

  def before_image_url
    before_image.file.url if before_image&.file.present?
  end
  
  def after_image_url
    after_image.file.url if after_image&.file.present?
  end
  
  def description_image_url
    description_image.file.url if description_image&.file.present?
  end
  
  def image_urls
    images.map { |img| img.file.url if img.file.present? }.compact
  end

  def category_list
    categories.pluck(:name)
  end

  def task_list
    tasks.pluck(:name)
  end
  

  private

  # def validate_tags
  #   invalid_tags = tag_list - ALLOWED_TAGS
  #   if invalid_tags.any?
  #     errors.add(:tag_list, "Есть невалидные теги: #{invalid_tags.join(', ')}. Разрешены только: #{ALLOWED_TAGS.join(', ')}")
  #   end
  # end
end
