class Api::V1::CommentsController < ApplicationController
	# skip_before_action :verify_authenticity_token, only: [:create]
  before_action :set_commentable

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
    if params[:question_id]
      @commentable = Question.find(params[:question_id])
    elsif params[:effect_id]
      @commentable = Effect.find(params[:effect_id])
    else
      render json: { error: "Invalid commentable type" }, status: :unprocessable_entity
    end
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
