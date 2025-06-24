json.extract! @effect, :id, :name, :img, :description, :speed, :platform, :manual, :program_version, :user_id, :created_at

# Информация об авторе эффекта
json.set! :author do
  if @effect.user
    json.extract! @effect.user, :id, :username, :avatar
  else
    json.nil!
  end
end

json.set! :comments do
  json.array! @effect.comments, partial: "api/v1/comments/comment", as: :comment
end

json.set! :ratings do
  json.array! @effect.ratings, partial: "api/v1/ratings/rating", as: :rating
end