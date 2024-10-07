class User < ApplicationRecord
    has_many :assets
    has_many :questions
    has_many :collections
end
