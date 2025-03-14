class Api::V1::CommentsController < ApplicationController
	# skip_before_action :verify_authenticity_token
  before_action :set_commentable

  before_action :authenticate_user!

  def index
    comments = @commentable.comments.includes(:user).where(parent_id: nil)
    render json: format_comments(comments)
  end

  def show
    comment = @commentable.comments.includes(:user).find_by(id: params[:id])
    
    if comment
      render json: format_comment(comment)
    else
      render json: { error: "Комментарий не найден" }, status: :not_found
    end
  end
  
  def create
    commentable = find_commentable
    return render json: { error: "Объект не найден" }, status: :not_found unless commentable

    parent_comment = nil
    if params[:parent_id].present?
      parent_comment = Comment.find_by(id: params[:parent_id])
      return render json: { error: "Родительский комментарий не найден" }, status: :not_found unless parent_comment
    end

    comment = commentable.comments.new(comment_params)
    comment.user = current_user
    comment.parent = parent_comment

    if comment.save
      render json: { message: "Комментарий создан", comment: comment }, status: :created
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    comment = @commentable.comments.find_by(id: params[:id])
    return render json: { error: "Комментарий не найден" }, status: :not_found unless comment

    unless comment.user == current_user
      return render json: { error: "Вы не можете редактировать этот комментарий" }, status: :forbidden
    end

    if comment.update(comment_params)
      render json: { message: "Комментарий обновлён", comment: comment }, status: :ok
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
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

  def authenticate_user!
    render json: { error: "Не авторизован" }, status: :unauthorized unless current_user
  end
  

  def set_commentable
    @commentable =
      if params[:question_id]
        Question.find_by(id: params[:question_id])
      elsif params[:effect_id]
        Effect.find_by(id: params[:effect_id])
      end
  
    render json: { error: "Объект не найден" }, status: :not_found unless @commentable
  end
  

	def find_commentable
    if params[:effect_id]
      Effect.find_by(id: params[:effect_id])
    elsif params[:question_id]
      Question.find_by(id: params[:question_id])
    else
      nil
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def format_comments(comments)
    comments.map { |comment| format_comment(comment) }
  end

  def format_comment(comment)
    comment.as_json(only: [:id, :body, :created_at], include: { user: { only: [:username, :avatar] } }).merge({
      replies: format_comments(comment.replies)
    })
  end

  def current_user
    User.find_by_jti(decrypt_payload[0]['jti'])
  end

  def decrypt_payload
    jwt = request.headers["Authorization"]
    JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
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
