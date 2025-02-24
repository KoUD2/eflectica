class Api::V1::QuestionsController < ApplicationController
  # skip_before_action :verify_authenticity_token, only: [:create]

  def index
    @questions = Question.includes(:comments).all
    render json: @questions.as_json(
      only: [:id, :title, :media, :description],
      methods: [:tag_list]
    )
  end

  def show
    @question = Question.includes(:comments).find(params[:id])
    render json: @question.as_json(
      only: [:id, :title, :media, :description],
      methods: [:tag_list]
    )
  end

  def create
    user = User.find_by_jti(decrypt_payload[0]['jti'])
    question = user.questions.new(question_params)

    if question.save
      render json: question, status: :created
    else
      render json: question.errors, status: :unprocessable_entity
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :media, :description, :user_id, tag_list: [])
  end

  def decrypt_payload
    jwt = request.headers["Authorization"]
    token = JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  end

  #   def decrypt_payload
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
