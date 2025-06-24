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