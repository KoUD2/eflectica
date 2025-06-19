class EffectProgram < ApplicationRecord
	has_many :user_effect_programs, dependent: :destroy
  has_many :users, through: :user_effect_programs
  
  # Связь с эффектами через связующую таблицу
  has_many :effect_effect_programs, dependent: :destroy
  has_many :effects, through: :effect_effect_programs
end
