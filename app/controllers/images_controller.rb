class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_collection

  def create
    @image = @collection.images.new(image_params)
    
    if @image.save
      CollectionImage.create!(collection: @collection, image: @image)
      redirect_to @collection, notice: "Референс добавлен!"
    else
      redirect_to @collection, alert: "Ошибка: #{@image.errors.full_messages.join(', ')}"
    end
  end
  

  private

  def set_collection
    @collection = current_user.collections.find(params[:collection_id])
  end

  def image_params
    params.require(:image).permit(:title, :file)
  end
end
