class CommentsController < ApplicationController
  before_action :set_effect
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!

  def index
    @comments = @effect.comments
  end

  def show
  end

  def new
    @comment = @effect.comments.new
  end

  def edit
  end

  def create
    # Получаем параметры из запроса
    comment_data = params.require(:comment).permit(:body)
    rating_data = params.require(:comment).permit(rating_attributes: [:number])[:rating_attributes]
    
    # Транзакция для атомарного создания комментария и рейтинга
    ActiveRecord::Base.transaction do
      # Создаем комментарий
      @comment = @effect.comments.new(body: comment_data[:body], user_id: current_user.id)
      
      if @comment.save
        # Если есть данные о рейтинге и он не пустой
        if rating_data && rating_data[:number].present?
          # Создаем рейтинг, связанный с комментарием
          rating = Rating.new(
            number: rating_data[:number].to_i,
            user_id: current_user.id,
            ratingable_type: 'Comment',
            ratingable_id: @comment.id
          )
          
          unless rating.save
            raise ActiveRecord::Rollback
          end
        end
        
        render json: { message: "Comment created successfully" }, status: :created
      else
        render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end
  
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @effect, notice: "Комментарий был обновлен" }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to effect_comments_path(@effect), notice: "Комментарий был удален" }
      format.json { head :no_content }
    end
  end

  private

  def set_effect
    @effect = Effect.find(params[:effect_id])
  end

  def set_comment
    @comment = @effect.comments.find(params[:id])
  end
  
  def comment_params
    params.require(:comment).permit(:body, rating_attributes: [:number, :user_id])
  end
end
