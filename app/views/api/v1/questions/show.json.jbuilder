json.extract! @question, :id, :title, :media, :description

json.set! :comments do
  json.array! @question.comments, partial: "api/v1/comments/comment", as: :comment
end