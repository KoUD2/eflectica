class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :effects, dependent: :destroy
  has_many :favorites, dependent: :destroy
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

  mount_uploader :avatar, UserImageUploader

  # Валидации для профиля
  validates :username, uniqueness: true, length: { minimum: 3, maximum: 30 }, allow_blank: true
  validates :name, length: { maximum: 100 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :contact, length: { maximum: 100 }, allow_blank: true
  validates :portfolio, length: { maximum: 255 }, allow_blank: true

  def subscribed_to?(collection)
       sub_collections.exists?(collection: collection)
  end

  def is_admin?
       self.is_admin == true
  end
end
