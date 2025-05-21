class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:me]
  
  def index
    @users = User.includes(favorites: :effect).all
  end

  def show
    @user = User.includes(favorites: :effect).find(params[:id])
  end
  
  def me
    @user = current_user
    render json: @user.as_json(
      only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar],
      methods: [:favorites]
    )
  end
  
  private
  
  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end

  def current_user
    @current_user ||= User.find_by_jti(decrypt_payload[0]['jti']) if decrypt_payload
  rescue
    nil
  end

  def decrypt_payload
    jwt = request.headers["Authorization"]
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError => e
    nil
  end
end
