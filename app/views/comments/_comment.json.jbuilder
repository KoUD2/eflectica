json.extract! comment, :id, :body, :commentable_id, :commentable_type, :created_at, :updated_at
json.url comment_url(comment, format: :json)
