class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favorite, only: %i[ show edit update destroy ]

  # GET /favorites or /favorites.json
  def index
    @favorites = current_user.favorites.joins(:effect).merge(Effect.search(params[:search])).page(params[:page]).per(10)
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
    favorite = Favorite.new(user_id: current_user.id, effect_id: params[:effect_id])

    if favorite.save
      render json: { message: "Effect added to favorites successfully" }, status: :created
    else
      render json: { error: favorite.errors.full_messages }, status: :unprocessable_entity
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
      params.require(:favorite).permit(:effect_id)
    end
end
