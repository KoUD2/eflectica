class Api::V1::QuestionsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  before_action :authenticate_user!

  def index
    @questions = Question.includes(:images, :comments).all
    render json: @questions.as_json(
      only: [:id, :title, :description, :platform, :programs, :is_secure, :link_to],
      methods: [:category_list, :task_list, :before_image_url, :after_image_url, :description_image_url, :image_urls]
    )
  end
  
  def show
    @question = Question.includes(:images, :comments).find(params[:id])
    render json: @question.as_json(
      only: [:id, :title, :description, :platform, :programs, :is_secure, :link_to],
      methods: [:category_list, :task_list, :before_image_url, :after_image_url, :description_image_url, :image_urls]
    )
  end
  

  def create
    user = User.find_by_jti(decrypt_payload[0]['jti'])
    question = user.questions.new(question_params.except(:images, :before_image, :after_image, :description_image))
  
    if question.save
      if params[:question][:images].present?
        params[:question][:images].each do |img|
          question.images.create!(file: img, image_type: "general")
        end
      end
  
      if params[:question][:before_image].present?
        question.create_before_image!(file: params[:question][:before_image], image_type: "before")
      end
  
      if params[:question][:after_image].present?
        question.create_after_image!(file: params[:question][:after_image], image_type: "after")
      end
  
      if params[:question][:description_image].present?
        question.create_description_image!(file: params[:question][:description_image], image_type: "description")
      end
  
      render json: question, status: :created
    else
      render json: question.errors, status: :unprocessable_entity
    end
  end

  def update
    question = current_user.questions.find_by(id: params[:id])
    
    unless question
      render json: { error: "Вопрос не найден или у вас нет прав на редактирование" }, status: :not_found
      return
    end

    if question.update(question_params.except(:images, :before_image, :after_image, :description_image))
      update_images(question)
      render json: question.as_json(
        only: [:id, :title, :description, :platform, :programs, :is_secure, :link_to],
        methods: [:category_list, :task_list, :before_image_url, :after_image_url, :description_image_url, :image_urls]
      ), status: :ok
    else
      render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  rescue
    nil
  end

  def question_params
    params.require(:question).permit(
      :title, :description, :platform, :programs, :link_to, :is_secure, category_list: [], task_list: []
    )
  end

  def update_images(question)
    if params[:question][:images].present?
      question.images.destroy_all
      params[:question][:images].each do |img|
        question.images.create!(file: img, image_type: "general")
      end
    end

    if params[:question][:before_image].present?
      question.before_image&.destroy
      question.create_before_image!(file: params[:question][:before_image], image_type: "before")
    end

    if params[:question][:after_image].present?
      question.after_image&.destroy
      question.create_after_image!(file: params[:question][:after_image], image_type: "after")
    end

    if params[:question][:description_image].present?
      question.description_image&.destroy
      question.create_description_image!(file: params[:question][:description_image], image_type: "description")
    end
  end

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end

  def decrypt_payload
    jwt = request.headers["Authorization"]
    token = JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
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
