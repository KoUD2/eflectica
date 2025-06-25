json.extract! comment, :id, :body, :created_at

# Информация об авторе комментария
json.set! :author do
  if comment.user
    json.extract! comment.user, :id, :username, :avatar
  else
    json.nil!
  end
end
