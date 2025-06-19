class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favorite, only: %i[ show edit update ]

  # GET /favorites or /favorites.json
  def index
    @favorite_effects = current_user.favorites.includes(effect: :images).map(&:effect)
    @favorite_links = current_user.favorite_links.order(created_at: :desc)
    @favorite_images = current_user.favorite_images.order(created_at: :desc)
    @effects = @favorite_effects
    @programs = helpers.programs
    puts "Favorite effects count: #{@favorite_effects.count}"
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

  # DELETE /favorites/:effect_id or /favorites/:effect_id.json
  def destroy
    # Находим избранное по effect_id и current_user
    favorite = current_user.favorites.find_by(effect_id: params[:effect_id])
    
    if favorite
      favorite.destroy!
      respond_to do |format|
        format.html { redirect_to favorites_path, status: :see_other, notice: "Favorite was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to favorites_path, status: :see_other, alert: "Favorite not found." }
        format.json { render json: { error: "Favorite not found" }, status: :not_found }
      end
    end
  end

  def add_link
    favorite_link = current_user.favorite_links.build(
      name: params[:name],
      notes: params[:notes],
      url: params[:url]
    )

    if favorite_link.save
      render json: { 
        success: true, 
        message: "Ссылка успешно добавлена в избранное" 
      }, status: :created
    else
      render json: { 
        success: false, 
        error: favorite_link.errors.full_messages.join(', ') 
      }, status: :unprocessable_entity
    end
  end

  def add_image
    favorite_image = current_user.favorite_images.build(
      title: params[:title],
      notes: params[:notes]
    )

    # Обработка загрузки файла
    if params[:file].present?
      # Здесь можно добавить логику сохранения файла
      # Пока просто сохраняем название файла
      favorite_image.image_file_name = params[:file].original_filename
      favorite_image.image_content_type = params[:file].content_type
      favorite_image.image_file_size = params[:file].size
    end

    if favorite_image.save
      render json: { 
        success: true, 
        message: "Референс успешно добавлен в избранное" 
      }, status: :created
    else
      render json: { 
        success: false, 
        error: favorite_image.errors.full_messages.join(', ') 
      }, status: :unprocessable_entity
    end
  end

  def remove_link
    favorite_link = current_user.favorite_links.find(params[:link_id])
    if favorite_link.destroy
      render json: { success: true, message: "Ссылка удалена из избранного" }
    else
      render json: { success: false, error: "Ошибка при удалении ссылки" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Ссылка не найдена" }, status: :not_found
  end

  def update_link
    favorite_link = current_user.favorite_links.find(params[:link_id])
    if favorite_link.update(
      name: params[:favorite_link][:name] || params[:name],
      notes: params[:favorite_link][:notes] || params[:notes],
      url: params[:favorite_link][:url] || params[:url]
    )
      render json: { success: true, message: "Ссылка обновлена" }
    else
      render json: { success: false, error: favorite_link.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Ссылка не найдена" }, status: :not_found
  end

  def remove_image
    favorite_image = current_user.favorite_images.find(params[:image_id])
    if favorite_image.destroy
      render json: { success: true, message: "Референс удален из избранного" }
    else
      render json: { success: false, error: "Ошибка при удалении референса" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Референс не найден" }, status: :not_found
  end

  def update_image
    favorite_image = current_user.favorite_images.find(params[:image_id])
    if favorite_image.update(
      title: params[:favorite_image][:title] || params[:title],
      notes: params[:favorite_image][:notes] || params[:notes]
    )
      render json: { success: true, message: "Референс обновлен" }
    else
      render json: { success: false, error: favorite_image.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Референс не найден" }, status: :not_found
  end

  def show_link
    favorite_link = current_user.favorite_links.find(params[:link_id])
    render json: {
      id: favorite_link.id,
      name: favorite_link.name,
      notes: favorite_link.notes,
      url: favorite_link.url
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ссылка не найдена" }, status: :not_found
  end

  def show_image
    favorite_image = current_user.favorite_images.find(params[:image_id])
    render json: {
      id: favorite_image.id,
      title: favorite_image.title,
      description: favorite_image.notes,
      file_url: favorite_image.image_file_name ? asset_path('placeholder.svg') : nil,
      image_file_name: favorite_image.image_file_name
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Референс не найден" }, status: :not_found
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
