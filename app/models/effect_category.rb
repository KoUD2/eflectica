class EffectCategory < ApplicationRecord
	has_many :user_effect_categories, dependent: :destroy
  has_many :users, through: :user_effect_categories
  
  # Связь с эффектами через связующую таблицу
  has_many :effect_effect_categories, dependent: :destroy
  has_many :effects, through: :effect_effect_categories
end
