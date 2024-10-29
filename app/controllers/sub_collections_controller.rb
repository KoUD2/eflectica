class SubCollectionsController < ApplicationController
  before_action :set_sub_collection, only: %i[ show edit update destroy ]

  # GET /sub_collections or /sub_collections.json
  def index
    @sub_collections = SubCollection.all
  end

  # GET /sub_collections/1 or /sub_collections/1.json
  def show
  end

  # GET /sub_collections/new
  def new
    @sub_collection = SubCollection.new
  end

  # GET /sub_collections/1/edit
  def edit
  end

  # POST /sub_collections or /sub_collections.json
  def create
    @sub_collection = SubCollection.new(sub_collection_params)

    respond_to do |format|
      if @sub_collection.save
        format.html { redirect_to @sub_collection, notice: "Sub collection was successfully created." }
        format.json { render :show, status: :created, location: @sub_collection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sub_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sub_collections/1 or /sub_collections/1.json
  def update
    respond_to do |format|
      if @sub_collection.update(sub_collection_params)
        format.html { redirect_to @sub_collection, notice: "Sub collection was successfully updated." }
        format.json { render :show, status: :ok, location: @sub_collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sub_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sub_collections/1 or /sub_collections/1.json
  def destroy
    @sub_collection.destroy!

    respond_to do |format|
      format.html { redirect_to sub_collections_path, status: :see_other, notice: "Sub collection was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sub_collection
      @sub_collection = SubCollection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sub_collection_params
      params.require(:sub_collection).permit(:collection_id, :user_id)
    end
end
