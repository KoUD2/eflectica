class Link < ApplicationRecord
	has_many :collection_links
  has_many :collections, through: :collection_links
end
