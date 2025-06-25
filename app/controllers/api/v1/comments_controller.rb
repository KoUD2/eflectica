class Api::V1::CommentsController < Api::V1::BaseController
  before_action :set_effect
  before_action :authenticate_user!, except: [:index, :show]

  def index
    comments = @effect.comments.includes(:user).where(parent_id: nil)
    render json: format_comments(comments)
  end

  def show
    comment = @effect.comments.includes(:user).find_by(id: params[:id])
    
    if comment
      render json: format_comment(comment)
    else
      render json: { error: "Комментарий не найден" }, status: :not_found
    end
  end
  
  def create
    parent_comment = Comment.find_by(id: params[:parent_id]) if params[:parent_id].present?
    
    comment = @effect.comments.new(comment_params)
    comment.user = current_user
    comment.parent = parent_comment

    if comment.save
      render json: { 
        message: "Комментарий создан", 
        comment: format_comment(comment),
        average_rating: @effect.ratings.average(:number).to_f.round(2)
      }, status: :created
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    comment = @effect.comments.find_by(id: params[:id])
    return render json: { error: "Комментарий не найден" }, status: :not_found unless comment

    unless comment.user == current_user
      return render json: { error: "Вы не можете редактировать этот комментарий" }, status: :forbidden
    end

    if comment.update(comment_params)
      render json: { message: "Комментарий обновлён", comment: format_comment(comment) }, status: :ok
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = @effect.comments.find(params[:id])

    if comment.destroy
      render json: { message: "Комментарий удалён" }, status: :ok
    else
      render json: { error: "Ошибка удаления" }, status: :unprocessable_entity
    end
  end

  private

  def set_effect
    @effect = Effect.find_by(id: params[:effect_id])
    render json: { error: "Эффект не найден" }, status: :not_found unless @effect
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def format_comments(comments)
    comments.map { |comment| format_comment(comment) }
  end

  def format_comment(comment)
    comment.as_json(only: [:id, :body, :created_at], include: { 
      user: { only: [:username, :avatar] } 
    }).merge({
      replies: format_comments(comment.replies)
    })
  end


end
