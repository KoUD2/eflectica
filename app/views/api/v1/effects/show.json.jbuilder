json.extract! @effect, :id, :name, :img, :description, :speed, :devices, :manual

json.set! :comments do
  json.array! @effect.comments, partial: "api/v1/comments/comment", as: :comment
end

json.set! :ratings do
  json.array! @effect.ratings, partial: "api/v1/ratings/rating", as: :rating
end