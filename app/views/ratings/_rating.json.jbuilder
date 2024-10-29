json.extract! rating, :id, :number, :ratingable_id, :ratingable_type, :created_at, :updated_at
json.url rating_url(rating, format: :json)
