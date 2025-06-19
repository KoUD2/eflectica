class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: %i[ show edit update destroy ]

  # GET /links or /links.json
  def index
    @links = Link.all
  end

  # GET /links/1 or /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links or /links.json
  def create
    @link = Link.new(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to @link, notice: "Link was successfully created." }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /links/1 or /links/1.json
  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to @link, notice: "Link was successfully updated." }
        format.json { render json: { success: true, message: "Ссылка обновлена" } }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, error: @link.errors.full_messages.join(", ") }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1 or /links/1.json
  def destroy
    begin
      @link.destroy!
      
      respond_to do |format|
        format.html { redirect_to links_path, status: :see_other, notice: "Link was successfully destroyed." }
        format.json { render json: { success: true, message: "Ссылка успешно удалена" } }
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      respond_to do |format|
        format.html { redirect_to links_path, alert: "Не удалось удалить ссылку: #{e.message}" }
        format.json { render json: { success: false, error: "Не удалось удалить ссылку: #{e.message}" }, status: :unprocessable_entity }
      end
    rescue StandardError => e
      respond_to do |format|
        format.html { redirect_to links_path, alert: "Произошла ошибка при удалении ссылки" }
        format.json { render json: { success: false, error: "Произошла ошибка при удалении ссылки" }, status: :internal_server_error }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
      
      # Проверяем, что ссылка принадлежит коллекции текущего пользователя
      user_collections = current_user.collections.joins(:collection_links).where(collection_links: { link_id: @link.id })
      unless user_collections.exists?
        respond_to do |format|
          format.html { redirect_to root_path, alert: "У вас нет прав для редактирования этой ссылки" }
          format.json { render json: { success: false, error: "У вас нет прав для редактирования этой ссылки" }, status: :forbidden }
        end
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def link_params
      params.require(:link).permit(:path, :title, :description)
    end
end
