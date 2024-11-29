json.extract! user, :id, :email, :username, :bio, :contact, :portfolio, :is_admin, :avatar, :encrypted_password
json.url api_v1_user_url(user)