class Api::V1::LikesController < ApplicationController
	# skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

	 def index
    likeable = find_likeable
    return render json: { error: "Объект не найден" }, status: :not_found unless likeable

    likes = likeable.likes
    render json: { likes: likes }
  end

  def show
    likeable = find_likeable
    return render json: { error: "Объект не найден" }, status: :not_found unless likeable

    like = likeable.likes.find_by(id: params[:id])
    if like
      render json: { like: like }
    else
      render json: { error: "Лайк не найден" }, status: :not_found
    end
  end

  def create
    likeable = find_likeable
    return render json: { error: "Объект не найден" }, status: :not_found unless likeable

    like = likeable.likes.new(user: current_user)

    if like.save
      render json: { message: "Лайк поставлен", like_count: likeable.likes.count }
    else
      render json: { error: like.errors.full_messages }, status: :unprocessable_entity
    end
  end

	def destroy
    like_id = params[:id]
    like = Like.find_by(id: like_id, user: current_user)

    if like
      likeable = like.likeable
      like.destroy
      render json: { message: "Лайк удален", like_count: likeable.likes.count }
    else
      render json: { error: "Лайк не найден" }, status: :not_found
    end
  end

  private

  def find_likeable
    likeable_type = params[:likeable_type].capitalize.constantize
    likeable_type.find_by(id: params[:likeable_id]) rescue nil
  end

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end

  def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  rescue
    nil
  end

	def decrypt_payload
    jwt = request.headers["Authorization"]
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  end

  # def decrypt_payload
  #   auth_header = request.headers["Authorization"]
  #   return nil if auth_header.blank?

  #   puts "Authorization Header: #{request.headers['Authorization'].inspect}"

  #   jwt = auth_header.split(' ').last
  #   puts "Decoded JWT: #{jwt}"
  #   JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  # rescue JWT::DecodeError => e
  #   puts "JWT Decode Error: #{e.message}"
  #   nil
  # end
end
