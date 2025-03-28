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
    comment_params = params.require(:comment).permit(:body, rating_attributes: [:number])

    @comment = @effect.comments.new(comment_params.merge(user_id: current_user.id))

    if @comment.save
      render json: { message: "Comment created successfully" }, status: :created
    else
      render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
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
    params.require(:comment).permit(:body, rating_attributes: [:number])
  end
end
