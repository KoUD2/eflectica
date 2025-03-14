class Api::V1::SubCollectionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!
  before_action :set_subscription, only: [:show, :destroy]

  def index
    @subscriptions = current_user.sub_collections
    render json: @subscriptions
  end

  def show
    render json: @subscription
  end

  def create
    collection = Collection.find_by(id: params[:collection_id], status: 'public')
    
    unless collection
      render json: { error: 'Публичная коллекция не найдена' }, status: :not_found
      return
    end

    subscription = current_user.sub_collections.new(collection: collection)

    if subscription.save
      render json: subscription, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
		if @subscription
			@subscription.destroy
			head :no_content
		else
			render json: { error: "Не удалось найти подписку" }, status: :not_found
		end
	end

  private

	def set_subscription
		@subscription = current_user.sub_collections.find_by(id: params[:id])
		return if @subscription
	
		render json: { error: "Подписка не найдена или доступ запрещен" }, status: :not_found
	end

  def subscription_params
    params.permit(:collection_id).tap do |whitelisted|
      if params[:action_type] == 'unsubscribe'
        whitelisted[:collection_id] = nil
      end
    end
  end

  def current_user
    @current_user ||= User.find_by_jti(decrypt_payload[0]['jti'])
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
