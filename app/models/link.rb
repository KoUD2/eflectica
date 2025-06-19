class Link < ApplicationRecord
	has_many :collection_links, dependent: :destroy
  has_many :collections, through: :collection_links
end
