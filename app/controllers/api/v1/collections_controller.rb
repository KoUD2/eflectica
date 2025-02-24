class Api::V1::CollectionsController < ApplicationController
  # skip_before_action :verify_authenticity_token, only: [:create]

  def index
    @collections = Collection.includes(:ratings).all
    render json: @collections.as_json(
      only: [:id, :name, :description, :user_id],
      methods: [:tag_list]
    )
  end

  def show
    @collection = Collection.includes(:ratings).find(params[:id])
    render json: @collection.as_json(
      only: [:id, :name, :description, :user_id],
      methods: [:tag_list]
    )
  end

  def create
    puts "Decoded Token: #{decrypt_payload.inspect}"

    user = User.find_by_jti(decrypt_payload[0]['jti'])
     puts "Переданные теги: #{params[:collection][:tag_list].inspect}"
    collection = user.collections.new(collection_params)

    if collection.save
      render json: collection, status: :created
    else
      render json: collection.errors, status: :unprocessable_entity
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :user_id, tag_list: [])
  end
  

  def decrypt_payload
    jwt = request.headers["Authorization"]
    puts "Received JWT: #{jwt.inspect}"
    token = JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  end

  # def decrypt_payload
  #   auth_header = request.headers["Authorization"]
  #   return nil if auth_header.blank?

  #   puts "Authorization Header: #{request.headers['Authorization'].inspect}"

  
  #   jwt = auth_header.split(' ').last # Берём только сам токен
  #   puts "Decoded JWT: #{jwt}" # Лог для проверки
  #   JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  # rescue JWT::DecodeError => e
  #   puts "JWT Decode Error: #{e.message}"
  #   nil
  # end
end
