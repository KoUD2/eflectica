json.extract! user, :id, :username, :bio, :contact, :portfolio, :speed, :is_admin, :avatar, :email, :password, :created_at, :updated_at
json.url user_url(user, format: :json)
