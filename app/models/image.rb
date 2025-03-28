class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  mount_uploader :file, ImageUploader
  has_many :collection_images, dependent: :destroy
  has_many :collections, through: :collection_images

	validates :image_type, presence: true, inclusion: { in: %w[before after description] }

  # validates :title, presence: { message: "Введите название" }
  # validates :file, presence: { message: "Выберите файл" }

  def image_url
    file.url
  end
end
