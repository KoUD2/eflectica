class UserEffectCategory < ApplicationRecord
  belongs_to :user
  belongs_to :effect_category
end
