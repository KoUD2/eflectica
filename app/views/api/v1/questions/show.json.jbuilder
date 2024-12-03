json.extract! @question, :id, :title, :media, :description, :user_id

json.set! :comments do
  json.array! @question.comments, partial: "api/v1/comments/comment", as: :comment
end