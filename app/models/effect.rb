class Effect < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :ratings, as: :ratingable
  has_many :collection_effects, dependent: :destroy
  has_many :collections, through: :collection_effects
  has_many :news_feeds, dependent: :destroy

  # Связи с программами, категориями и задачами через связующие таблицы
  has_many :effect_effect_programs, dependent: :destroy
  has_many :effect_programs, through: :effect_effect_programs, source: :effect_program
  
  accepts_nested_attributes_for :effect_programs, allow_destroy: true
  
  has_many :effect_effect_categories, dependent: :destroy
  has_many :categories_list, through: :effect_effect_categories, source: :effect_category
  
  has_many :effect_effect_tasks, dependent: :destroy
  has_many :tasks_list, through: :effect_effect_tasks, source: :effect_task

  has_many :images, as: :imageable, dependent: :destroy
  has_one :before_image, -> { where(image_type: "before") }, class_name: "Image", as: :imageable, dependent: :destroy
  has_one :after_image, -> { where(image_type: "after") }, class_name: "Image", as: :imageable, dependent: :destroy

  mount_uploader :img, EffectImageUploader

  acts_as_taggable_on :categories, :tasks

  scope :approved, -> { where(is_secure: "Одобрено") }

  validates :name, presence: true
  validates :description, presence: true
  validates :img, presence: true
  validates :speed, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 10
  }

  scope :search, ->(query) {
    return all if query.blank?

    query_downcased = "%#{query.downcase}%"
    where('LOWER(name) LIKE ? OR LOWER(description) LIKE ?', query_downcased, query_downcased)
  }

  ALLOWED_TAGS = [ "photoProcessing", "3dGrafics", "motion", "illustration", "animation", "uiux", "videoProcessing", "vfx", "gamedev", "arvr"].freeze

  def first_image
    images.find_by(image_type: 'description')
  end

  def other_images(limit = 4)
    images.where(image_type: 'description').limit(limit)
  end

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

  # Методы для работы с новыми связями
  def programs_list
    effect_programs.pluck(:name) rescue []
  end

  def programs_with_versions
    effect_programs.pluck(:name, :version).map { |name, version| { name: name, version: version } } rescue []
  end

  def category_list
    # Сохраняем старый метод для совместимости с тегами
    begin
      (categories.pluck(:name) + categories_list.pluck(:name)).uniq
    rescue
      []
    end
  end

  def task_list
    # Сохраняем старый метод для совместимости с тегами
    begin
      (tasks.pluck(:name) + tasks_list.pluck(:name)).uniq
    rescue
      []
    end
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
