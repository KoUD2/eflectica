class EffectsController < ApplicationController
  # load_and_authorize_resource
  # before_action :authenticate_user!
  before_action :set_effect, only: [:show, :edit, :update, :destroy, :approve, :reject]

  # GET /effects or /effects.json
  def index
    @top_effects = Effect.limit(5)
    @effects = Effect.search(params[:search]).page(params[:page]).per(12)
    @services = YAML.load_file(Rails.root.join("config/services/app.yml"))["services"]

    @collections = Collection.includes(effects: :images).limit(3)

    @categories = ["photoProcessing", "3dGrafics", "motion", "illustration", "animation", "uiux", "videoProcessing", "vfx", "gamedev", "arvr"]

    @collectionsFeed = Collection.joins(effects: :collection_effects)
    .where("effects.programs LIKE ? OR effects.programs LIKE ?", "%photoshop%", "%lightroom%")
    .distinct
    .limit(3)

    @filtered_effects = Effect.where("programs LIKE ? OR programs LIKE ?", "%photoshop%", "%lightroom%")
  
    if params[:programs].present?
      selected_programs = params[:programs]
      @effects = @effects.select do |effect|
        (selected_programs & effect.programs.split(',')).any?
      end
    end
  
    respond_to do |format|
      format.html
      format.js
    end
  end

  def categorie
    @category = params[:category]
    @effects = Effect.tagged_with(@category, on: :categories)
  end

  def categories
    @effects = Effect.includes(:images, :taggings)
    @categories = ActsAsTaggableOn::Tag
      .for_context(:categories)
      .distinct
      .pluck(:name)
    
    @programs = YAML.load_file(Rails.root.join("config/services/app.yml"))["programs"]
  end
  

  def by_tag
    @effects = Effect.tagged_with(params[:tag])
    render :index
  end

  # GET /effects/1 or /effects/1.json
  def show
    @effect = Effect.includes(comments: { user: :ratings }).find(params[:id])
    @effects = Effect.where.not(id: @effect.id).limit(4)
    @user_collections = current_user.collections
    @comment = Comment.new
  end

  # GET /effects/new
  def new
    render layout: 'application'
    @effect = Effect.new
  end

  # GET /effects/1/edit
  def edit
  end

  # POST /effects or /effects.json
  def create
    @effect = Effect.new(effect_params)
    @effect.user = current_user

    attach_images

    respond_to do |format|
      if @effect.save
        format.html { redirect_to @effect, notice: "Эффект был успешно создан" }
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
        format.html { redirect_to @effect, notice: "Эффект был обновлен" }
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
      format.html { redirect_to effects_path, status: :see_other, notice: "Эффект был удален" }
      format.json { head :no_content }
    end
  end

  def approve
    if @effect.update(is_secure: "Одобрено")
      redirect_to @effect, notice: 'Эффект одобрен'
    else
      redirect_to @effect, alert: 'Ошибка одобрения'
    end
  end
  
  def reject
    if @effect.update(is_secure: "Не одобрено")
      redirect_to @effect, notice: 'Эффект отклонен'
    else
      redirect_to @effect, alert: 'Ошибка отклонения'
    end
  end
  
  def my
    @effects = current_user.effects.order(created_at: :desc)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_effect
      @effect = Effect.find(params[:id])
    end

    def set_devise_resource
      self.resource = User.new
      self.resource_name = :user
      self.devise_mapping = Devise.mappings[:user]
    end

    # Only allow a list of trusted parameters through.
    def effect_params
      params.permit(:name, :description, :image_before, :image_after, :manual, :programs, :platform, :category_list, :program_version, :link_to)
    end

    def set_authorization_flag
      @author_or_admin = current_user && current_user.is_admin?
    end
    

    def attach_images
      @effect.image_before.attach(params[:image_before]) if params[:image_before]
      @effect.image_after.attach(params[:image_after]) if params[:image_after]
    end
end
