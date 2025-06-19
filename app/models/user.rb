class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :effects, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_links, dependent: :destroy
  has_many :favorite_images, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :news_feeds, dependent: :destroy
  has_many :sub_collections
  has_many :images, as: :imageable, dependent: :destroy
  has_many :subscribed_collections, 
  through: :sub_collections, 
  source: :collection
  has_many :likes, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_effect_categories, dependent: :destroy
  has_many :preferred_categories, through: :user_effect_categories, source: :effect_category
  
  has_many :user_effect_programs, dependent: :destroy
  has_many :preferred_programs, through: :user_effect_programs, source: :effect_program

  mount_uploader :avatar, UserImageUploader

  # Валидации для профиля
  validates :username, uniqueness: true, length: { minimum: 3, maximum: 30 }, allow_blank: true
  validates :name, length: { maximum: 100 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :contact, length: { maximum: 100 }, allow_blank: true
  validates :portfolio, length: { maximum: 255 }, allow_blank: true

  def personalized_feed
    return Effect.all if preferred_categories.empty? && preferred_programs.empty?
    
    effect_ids = []
    
    # Получаем эффекты по категориям
    if preferred_categories.any?
      category_effect_ids = Effect.joins(:categories_list)
                                  .where(effect_categories: { id: preferred_categories.ids })
                                  .pluck(:id)
      effect_ids.concat(category_effect_ids)
    end
    
    # Получаем эффекты по программам (новый способ через таблицы связей)
    if preferred_programs.any?
      program_effect_ids = Effect.joins(:effect_programs)
                                 .where(effect_programs: { id: preferred_programs.ids })
                                 .pluck(:id)
      effect_ids.concat(program_effect_ids)
    end
    
    # Возвращаем эффекты по найденным ID
    Effect.where(id: effect_ids.uniq)
  end

  def subscribed_to?(collection)
       sub_collections.exists?(collection: collection)
  end

  def is_admin?
       self.is_admin == true
  end
end
