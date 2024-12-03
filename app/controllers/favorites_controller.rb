class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favorite, only: %i[ show edit update destroy ]

  # GET /favorites or /favorites.json
  def index
    @favorites = current_user.favorites.includes(:effect)
    puts "Favorites count: #{@favorites.count}"
  end
  
  def by_tag
    @favorites = Favorite.tagged_with(params[:tag])
    render :index
  end

  # GET /favorites/1 or /favorites/1.json
  def show
  end

  # GET /favorites/new
  def new
    @favorite = current_user.favorites.new
  end

  # GET /favorites/1/edit
  def edit
  end

  # POST /favorites or /favorites.json
  def create
    @favorite = current_user.favorites.build(favorite_params)
  
    if @favorite.save
      redirect_to favorites_path, notice: "Favorite was successfully created."
    else
      Rails.logger.error("Failed to save favorite: #{@favorite.errors.full_messages}")
      redirect_to favorites_path, alert: "Failed to create favorite."
    end
  end
  
  

  # PATCH/PUT /favorites/1 or /favorites/1.json
  def update
    respond_to do |format|
      if @favorite.update(favorite_params)
        format.html { redirect_to @favorite, notice: "Favorite was successfully updated." }
        format.json { render :show, status: :ok, location: @favorite }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @favorite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favorites/1 or /favorites/1.json
  def destroy
    @favorite.destroy!

    respond_to do |format|
      format.html { redirect_to favorites_path, status: :see_other, notice: "Favorite was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite
      @favorite = Favorite.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def favorite_params
      params.require(:favorite).permit(:effect_id, :tag_list)
    end
end
