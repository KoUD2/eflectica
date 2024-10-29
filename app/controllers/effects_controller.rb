class EffectsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_effect, only: %i[ show edit update destroy ]

  # GET /effects or /effects.json
  def index
    @effects = Effect.all
  end

  # GET /effects/1 or /effects/1.json
  def show
    @effect = Effect.find(params[:id])
  end

  # GET /effects/new
  def new
    @effect = Effect.new
  end

  # GET /effects/1/edit
  def edit
  end

  # POST /effects or /effects.json
  def create
    @effect = Effect.new(effect_params)
    @effect.user = current_user

    respond_to do |format|
      if @effect.save
        format.html { redirect_to @effect, notice: "Effect was successfully created." }
        format.json { render :show, status: :created, location: @effect }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @effect.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /effects/1 or /effects/1.json
  def update
    respond_to do |format|
      if @effect.update(effect_params)
        format.html { redirect_to @effect, notice: "Effect was successfully updated." }
        format.json { render :show, status: :ok, location: @effect }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @effect.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /effects/1 or /effects/1.json
  def destroy
    @effect = Effect.find(params[:id])
  
    # Сначала удаляем связанные комментарии, рейтинги и коллекционные эффекты
    @effect.comments.destroy_all
    @effect.ratings.destroy_all
    @effect.collection_effects.destroy_all
  
    # Теперь можно удалить сам эффект
    @effect.destroy
  
    respond_to do |format|
      format.html { redirect_to effects_path, status: :see_other, notice: "Effect was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_effect
      @effect = Effect.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def effect_params
      params.require(:effect).permit(:name, :img, :description, :speed, :devices, :manual, :link_to, :is_secure, :user_id)
    end
end
