class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  mount_uploader :file, ImageUploader

	validates :image_type, presence: true, inclusion: { in: %w[before after description] }
end
