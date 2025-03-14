class Api::V1::CollectionEffectsController < ApplicationController
	skip_before_action :verify_authenticity_token
	
	before_action :authenticate_user! 
  before_action :set_collection
      
  def create
    effect = Effect.find(params[:effect_id])
    
    if @collection.user_id != current_user.id
      render json: { error: 'Вы можете добавлять эффекты только в свои коллекции' }, status: :forbidden
      return
    end
  
    collection_effect = @collection.collection_effects.new(effect: effect)
  
    if collection_effect.save
      render json: collection_effect, status: :created
    else
      render json: { errors: collection_effect.errors.full_messages }, status: :unprocessable_entity
    end
  
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Эффект с ID #{params[:effect_id]} не найден" }, status: :not_found
  end
  

  private

	def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  rescue
    nil
  end

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end

  def set_collection
    @collection = Collection.find(params[:collection_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Коллекция не найдена' }, status: :not_found
  end

	  # def decrypt_payload
  #   jwt = request.headers["Authorization"]
  #   puts "Received JWT: #{jwt.inspect}"
  #   token = JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  # end

	def decrypt_payload
    auth_header = request.headers["Authorization"]
    puts "All headers: #{request.headers.inspect}"
    puts "Authorization Header: #{auth_header.inspect}"
  
    return nil if auth_header.blank?
  
    jwt = auth_header.split(' ').last
    puts "Decoded JWT: #{jwt}"
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError => e
    puts "JWT Decode Error: #{e.message}"
    nil
  end
end