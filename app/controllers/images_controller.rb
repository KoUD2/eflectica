class ImagesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :authenticate_user_for_json!, only: [:show]
  before_action :set_collection, only: [:create]
  before_action :set_image, only: [:show, :update, :destroy]
  before_action :set_cors_headers, only: [:show]

  def create
    @image = Image.new(image_params)
    @image.imageable = @collection
    @image.image_type = 'description' # Установим тип image_type для референса
    
    if @image.save
      CollectionImage.create!(collection: @collection, image: @image)
      redirect_to @collection, notice: "Референс добавлен!"
    else
      redirect_to @collection, alert: "Ошибка: #{@image.errors.full_messages.join(', ')}"
    end
  end

  def show
    respond_to do |format|
      format.html do
        if @image.file.present?
          # Отправляем файл с правильными заголовками
          send_file @image.file.path, 
                    type: @image.file.content_type,
                    disposition: 'inline',
                    filename: @image.file.filename
        else
          head :not_found
        end
      end
      
      format.json do
        render json: {
          id: @image.id,
          title: @image.title,
          description: @image.description,
          file_url: @image.file.present? ? image_path(@image) : nil,
          created_at: @image.created_at
        }
      end
    end
  end

  def update
    if @image.update(image_update_params)
      respond_to do |format|
        format.json { render json: { success: true, message: 'Референс обновлен' } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: @image.errors.full_messages.join(', ') } }
      end
    end
  end

  def destroy
    collection = @image.collection_images.first&.collection
    @image.destroy
    
    respond_to do |format|
      format.json { render json: { success: true, message: 'Референс удален' } }
    end
  end

  private

  def authenticate_user_for_json!
    if request.format.json? && !user_signed_in?
      render json: { error: 'Требуется авторизация' }, status: :unauthorized
    end
  end

  def set_collection
    @collection = current_user.collections.find(params[:collection_id])
  end

  def set_image
    @image = Image.find(params[:id])
    
    # Проверяем, что пользователь имеет доступ к изображению через его коллекции (только для аутентифицированных пользователей)
    if user_signed_in?
      collection = @image.collection_images.joins(:collection).where(collections: { user: current_user }).first&.collection
      
      unless collection
        respond_to do |format|
          format.html { head :forbidden }
          format.json { render json: { error: 'Доступ запрещен' }, status: :forbidden }
        end
        return
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { head :not_found }
      format.json { render json: { error: 'Изображение не найдено' }, status: :not_found }
    end
  end

  def image_params
    params.require(:image).permit(:title, :file, :description)
  end

  def image_update_params
    params.require(:image).permit(:title, :description, :file)
  end

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS, HEAD'
    response.headers['Access-Control-Allow-Headers'] = '*'
  end
end
