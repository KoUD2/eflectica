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

  def subscribed_to?(collection)
       sub_collections.exists?(collection: collection)
  end

  def is_admin?
       self.is_admin == true
       end
     

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
