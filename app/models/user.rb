class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :effects, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :news_feeds, dependent: :destroy
  has_many :sub_collections, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  has_many :subscribed_collections, 
  through: :sub_collections, 
  source: :collection
  has_many :likes, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
