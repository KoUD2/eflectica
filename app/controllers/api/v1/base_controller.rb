class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  protected

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end

  def current_user
    @current_user ||= User.find_by_jti(decrypt_payload[0]['jti']) if decrypt_payload
  rescue
    nil
  end

  private

  def decrypt_payload
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?
    
    # Извлекаем JWT из заголовка, удаляя префикс Bearer если он есть
    jwt = auth_header.start_with?('Bearer ') ? auth_header.gsub('Bearer ', '') : auth_header
    
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  rescue JWT::DecodeError => e
    nil
  end
end 