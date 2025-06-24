json.extract! @effect, :id, :name, :img, :description, :speed, :platform, :manual, :program_version, :user_id, :created_at

# Информация об авторе эффекта
json.set! :author do
  if @effect.user
    json.extract! @effect.user, :id, :username, :avatar
  else
    json.nil!
  end
end

# Категории эффекта
json.categories @effect.category_list

# Задачи эффекта
json.tasks @effect.task_list

# Программы с версиями
json.programs @effect.programs_with_versions

# Средний рейтинг
json.average_rating @effect.average_rating

# Before и After изображения
json.before_image @effect.before_image
json.after_image @effect.after_image

json.set! :comments do
  json.array! @effect.comments, partial: "api/v1/comments/comment", as: :comment
end

json.set! :ratings do
  json.array! @effect.ratings, partial: "api/v1/ratings/rating", as: :rating
end