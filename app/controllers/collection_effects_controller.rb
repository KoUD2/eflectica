class CollectionEffectsController < ApplicationController
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
    @collection_effect = CollectionEffect.new(collection_effect_params)

    if @collection_effect.save
      redirect_to collections_path, notice: "Effect was successfully added to collection."
    else
      redirect_to collections_path, alert: "Failed to add effect to collection."
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
      format.html { redirect_to collection_effects_path, status: :see_other, notice: "Collection effect was successfully destroyed." }
      format.json { head :no_content }
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
