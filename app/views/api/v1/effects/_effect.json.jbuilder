json.extract! effect, :id, :name, :img, :description, :speed, :platform, :manual, :created_at
json.url api_v1_effect_url(effect)

# Информация об авторе эффекта
json.set! :author do
  if effect.user
    json.extract! effect.user, :id, :username, :avatar
  else
    json.nil!
  end
end

# Категории эффекта
json.categories effect.category_list

# Задачи эффекта
json.tasks effect.task_list

# Программы с версиями
json.programs effect.programs_with_versions

# Средний рейтинг
json.average_rating effect.average_rating

# Before и After изображения
json.before_image effect.before_image
json.after_image effect.after_image