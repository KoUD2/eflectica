class FavoriteImage < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  # Paperclip configuration (если используется)
  # has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }
  # validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
end 