class Favorite < ApplicationRecord
  belongs_to :asset
  belongs_to :user
end
