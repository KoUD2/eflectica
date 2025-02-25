class Api::V1::CommentsController < ApplicationController
	# skip_before_action :verify_authenticity_token, only: [:create]
  before_action :set_commentable

  def index
    comments = @commentable.comments.includes(:user)
    render json: comments.as_json(only: [:id, :body, :created_at], include: { user: { only: [:username, :avatar] } })
  end

  def show
    comment = @commentable.comments.includes(:user).find_by(id: params[:id])
  
    if comment
      render json: comment.as_json(only: [:id, :body, :created_at], include: { user: { only: [:username, :avatar] } })
    else
      render json: { error: "Комментарий не найден" }, status: :not_found
    end
  end
  
  

  def create
    comment = @commentable.comments.new(comment_params.merge(user: current_user))

    if comment.save
      render json: comment, status: :created
    else
      render json: comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    comment = @commentable.comments.find(params[:id])

    if comment.destroy
      render json: { message: "Комментарий удалён" }, status: :ok
    else
      render json: { error: "Ошибка удаления" }, status: :unprocessable_entity
    end
  end

  private

  def set_commentable
    @commentable =
      if params[:question_id]
        Question.find_by(id: params[:question_id])
      elsif params[:effect_id]
        Effect.find_by(id: params[:effect_id])
      end
  
    render json: { error: "Объект не найден" }, status: :not_found unless @commentable
  end
  

	def comment_params
		params.require(:comment).permit(:body)
	end	

  def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  end

  def decrypt_payload
    jwt = request.headers["Authorization"]
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
  end

	#   def decrypt_payload
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
