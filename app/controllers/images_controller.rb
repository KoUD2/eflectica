class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collection, only: [:create]
  before_action :set_image, only: [:show, :update, :destroy]

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
      format.json do
        render json: {
          id: @image.id,
          title: @image.title,
          description: @image.description,
          file_url: @image.file.present? ? @image.file.url : nil
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

  def set_collection
    @collection = current_user.collections.find(params[:collection_id])
  end

  def set_image
    @image = Image.find(params[:id])
    # Проверяем, что пользователь имеет доступ к изображению через его коллекции
    collection = @image.collection_images.joins(:collection).where(collections: { user: current_user }).first&.collection
    
    unless collection
      render json: { error: 'Доступ запрещен' }, status: :forbidden
      return
    end
  end

  def image_params
    params.require(:image).permit(:title, :file, :description)
  end

  def image_update_params
    params.require(:image).permit(:title, :description, :file)
  end
end
