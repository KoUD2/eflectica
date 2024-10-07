class Rating < ApplicationRecord
  belongs_to :retingable, polymorphic: true
end
