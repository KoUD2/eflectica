class EffectTask < ApplicationRecord
  # Связь с эффектами через связующую таблицу
  has_many :effect_effect_tasks, dependent: :destroy
  has_many :effects, through: :effect_effect_tasks
end
