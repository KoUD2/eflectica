class CollectionEffectsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_collection_effect, only: %i[ show edit update destroy ]

  # GET /collection_effects or /collection_effects.json
  def index
    @collection_effects = CollectionEffect.all
  end

  # GET /collection_effects/1 or /collection_effects/1.json
  def show
  end

  # GET /collection_effects/new
  def new
    @collection_effect = CollectionEffect.new
  end

  # GET /collection_effects/1/edit
  def edit
  end

  # POST /collection_effects or /collection_effects.json
  def create
    # Проверяем, что коллекция принадлежит текущему пользователю
    collection = current_user.collections.find_by(id: collection_effect_params[:collection_id])
    
    unless collection
      respond_to do |format|
        format.html { redirect_to collections_path, alert: "Коллекция не найдена" }
        format.json { render json: { error: "Коллекция не найдена" }, status: :not_found }
      end
      return
    end

    # Проверяем, что эффект еще не добавлен в коллекцию
    existing_effect = collection.collection_effects.find_by(effect_id: collection_effect_params[:effect_id])
    
    if existing_effect
      respond_to do |format|
        format.html { redirect_to collections_path, notice: "Эффект уже добавлен в коллекцию" }
        format.json { render json: { message: "Эффект уже добавлен в коллекцию" }, status: :ok }
      end
      return
    end

    @collection_effect = CollectionEffect.new(collection_effect_params)

    respond_to do |format|
      if @collection_effect.save
        format.html { redirect_to collections_path, notice: "Effect was successfully added to collection." }
        format.json { render json: { message: "Эффект добавлен в коллекцию" }, status: :created }
      else
        format.html { redirect_to collections_path, alert: "Failed to add effect to collection." }
        format.json { render json: { error: @collection_effect.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_effects/1 or /collection_effects/1.json
  def update
    respond_to do |format|
      if @collection_effect.update(collection_effect_params)
        format.html { redirect_to @collection_effect, notice: "Collection effect was successfully updated." }
        format.json { render :show, status: :ok, location: @collection_effect }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection_effect.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_effects/1 or /collection_effects/1.json
  def destroy
    @collection_effect.destroy!

    respond_to do |format|
      format.html { redirect_to collection_effects_path, status: :see_other, notice: "Коллекция была удалена" }
      format.json { head :no_content }
    end
  end

  # DELETE /collection_effects/:collection_id/:effect_id
  def destroy_by_ids
    Rails.logger.info "=== DESTROY_BY_IDS DEBUG ==="
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Collection ID: #{params[:collection_id]}"
    Rails.logger.info "Effect ID: #{params[:effect_id]}"
    Rails.logger.info "Current user: #{current_user&.id}"
    
    # Проверяем, что коллекция принадлежит текущему пользователю
    collection = current_user.collections.find_by(id: params[:collection_id])
    
    Rails.logger.info "Collection found: #{collection&.id}"
    
    unless collection
      Rails.logger.error "Collection not found or doesn't belong to user"
      respond_to do |format|
        format.html { redirect_to collections_path, alert: "Коллекция не найдена" }
        format.json { render json: { error: "Коллекция не найдена" }, status: :not_found }
      end
      return
    end

    @collection_effect = collection.collection_effects.find_by(effect_id: params[:effect_id])
    
    Rails.logger.info "Collection effect found: #{@collection_effect&.id}"

    if @collection_effect
      @collection_effect.destroy!
      Rails.logger.info "Collection effect destroyed successfully"
      respond_to do |format|
        format.html { redirect_to collections_path, notice: "Эффект удален из коллекции" }
        format.json { render json: { message: "Эффект удален из коллекции" }, status: :ok }
      end
    else
      Rails.logger.error "Collection effect not found"
      respond_to do |format|
        format.html { redirect_to collections_path, alert: "Эффект не найден в коллекции" }
        format.json { render json: { error: "Эффект не найден в коллекции" }, status: :not_found }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_effect
      @collection_effect = CollectionEffect.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_effect_params
      params.require(:collection_effect).permit(:collection_id, :effect_id)
    end
end
