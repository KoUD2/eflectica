class Api::V1::FavoritesController < ApplicationController
	skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def create
    favorite = current_user.favorites.new(effect_id: params[:effect_id])

    if favorite.save
      render json: { message: "Добавлено в избранное", favorite: favorite }, status: :created
    else
      render json: { error: favorite.errors.full_messages }, status: :unprocessable_entity
    end
  end

	def destroy
		favorite = current_user.favorites.find_by(effect_id: params[:effect_id])
	
		if favorite
			favorite.destroy
			render json: { message: "Удалено из избранного" }, status: :ok
		else
			render json: { error: "Запись не найдена" }, status: :not_found
		end
	end	

  private

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end

  def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  rescue
    nil
  end

  # def decrypt_payload
  #   jwt = request.headers["Authorization"]
  #   JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  # end

	  def decrypt_payload
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?

    puts "Authorization Header: #{request.headers['Authorization'].inspect}"

  
    jwt = auth_header.split(' ').last
    puts "Decoded JWT: #{jwt}"
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError => e
    puts "JWT Decode Error: #{e.message}"
    nil
  end
end
