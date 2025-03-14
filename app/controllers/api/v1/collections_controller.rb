class Api::V1::CollectionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!

  def index
    @collections = Collection.includes(:ratings, :effects).all
    render json: @collections.as_json(
      only: [:id, :name, :description, :status, :user_id],
      include: { effects: {} }
    )
  end

  def show
    @collection = Collection.includes(:ratings, :effects).find(params[:id])
    render json: @collection.as_json(
      only: [:id, :name, :description, :status, :user_id],
      include: { effects: {} }
    )
  end

  def create
    collection = current_user.collections.new(collection_params)

    if collection.save
      render json: { message: 'Коллекция успешно создана', collection: collection }, status: :created
    else
      render json: { error: collection.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    collection = current_user.collections.find_by(id: params[:id])

    if collection
      if collection.update(status: params[:status])
        render json: { message: 'Статус коллекции обновлен', collection: collection }, status: :ok
      else
        render json: { error: 'Ошибка обновления статуса коллекции' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Коллекция не найдена' }, status: :not_found
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :status, :user_id)
  end

  def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  rescue
    nil
  end

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
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
