class RatingsController < ApplicationController
  before_action :set_rating, only: %i[ show edit update destroy ]

  # GET /ratings or /ratings.json
  def index
    @ratings = Rating.all
  end

  # GET /ratings/1 or /ratings/1.json
  def show
  end

  # GET /ratings/new
  def new
    @question = Question.find(params[:question_id])
    @rating = @question.ratings.build
  end
  

  # GET /ratings/1/edit
  def edit
  end

  # POST /ratings or /ratings.json
  def create
    @parent = find_parent
    @rating = @parent.ratings.new(rating_params)
  
    @rating.user = User.first
  
    if @rating.save
      respond_to do |format|
        format.json { render json: { average_rating: @parent.ratings.average(:number).to_f.round(2) }, status: :created }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @rating.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /ratings/1 or /ratings/1.json
  def update
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to @rating, notice: "Rating was successfully updated." }
        format.json { render :show, status: :ok, location: @rating }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1 or /ratings/1.json
  def destroy
    @rating.destroy!

    respond_to do |format|
      format.html { redirect_to ratings_path, status: :see_other, notice: "Rating was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    def find_parent
      if params[:effect_id]
        Effect.find(params[:effect_id])
      elsif params[:question_id]
        Question.find(params[:question_id])
      else
        raise ActiveRecord::RecordNotFound, "No parent found"
      end
    end

    # Only allow a list of trusted parameters through.
    def rating_params
      params.require(:rating).permit(:number, :ratingable_id, :ratingable_type)
    end
end
