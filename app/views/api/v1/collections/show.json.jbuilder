json.extract! @collection, :id, :name, :description, :user_id

json.set! :ratings do
  json.array! @collection.ratings, partial: "api/v1/ratings/rating", as: :rating
end