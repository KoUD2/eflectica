class OgImagesController < ApplicationController
  require 'mini_magick'
  
  def effect
    @effect = Effect.find(params[:id])
    after_image = @effect.images.find_by(image_type: 'after')
    
    generate_og_image(after_image)
  end

  def collection
    @collection = Collection.find(params[:id])
    
    # Проверяем, есть ли эффекты в коллекции
    if @collection.effects.any?
      # Берем последний добавленный эффект в коллекцию
      latest_effect = @collection.effects.joins(:collection_effects)
                                 .order('collection_effects.created_at DESC')
                                 .first
      
      after_image = latest_effect&.images&.find_by(image_type: 'after')
      generate_og_image(after_image)
    else
      # Если в коллекции нет эффектов, используем дефолтное изображение
      generate_default_collection_image
    end
  end

  private

  def generate_og_image(after_image)
    if after_image&.file&.present?
      begin
        # Создаем изображение 1920x1080
        composite_image = MiniMagick::Image.open(after_image.file.path)
        
        # Изменяем размер изображения эффекта, сохраняя пропорции
        composite_image.resize "1920x1080^"
        composite_image.gravity "center"
        composite_image.crop "1920x1080+0+0"
        
        # Путь к логотипу
        logo_path = Rails.root.join('app', 'assets', 'images', 'A_LogoShare.svg')
        
        if File.exist?(logo_path)
          # Конвертируем SVG в PNG для работы с MiniMagick
          logo = MiniMagick::Image.open(logo_path)
          logo.format 'png'
          logo.resize "200x100" # Размер логотипа
          
          # Создаем композитное изображение
          result = composite_image.composite(logo) do |c|
            c.compose "Over"
            c.geometry "+860+40" # Позиция логотипа (по центру сверху)
          end
        else
          result = composite_image
        end
        
        # Возвращаем изображение
        send_data result.to_blob, type: 'image/png', disposition: 'inline'
        
      rescue => e
        Rails.logger.error "Ошибка генерации OG изображения: #{e.message}"
        redirect_to asset_path('default_og_image.png')
      end
    else
      redirect_to asset_path('default_og_image.png')
    end
  end

  def generate_default_collection_image
    begin
      # Путь к дефолтному изображению коллекции
      default_image_path = Rails.root.join('app', 'assets', 'images', 'opengraph_collection.png')
      
      if File.exist?(default_image_path)
        # Открываем дефолтное изображение
        composite_image = MiniMagick::Image.open(default_image_path)
        
        # Убеждаемся, что размер 1920x1080
        composite_image.resize "1920x1080!"
        
        # Путь к логотипу
        logo_path = Rails.root.join('app', 'assets', 'images', 'A_LogoShare.svg')
        
        if File.exist?(logo_path)
          # Конвертируем SVG в PNG для работы с MiniMagick
          logo = MiniMagick::Image.open(logo_path)
          logo.format 'png'
          logo.resize "200x100" # Размер логотипа
          
          # Создаем композитное изображение
          result = composite_image.composite(logo) do |c|
            c.compose "Over"
            c.geometry "+860+40" # Позиция логотипа (по центру сверху)
          end
        else
          result = composite_image
        end
        
        # Возвращаем изображение
        send_data result.to_blob, type: 'image/png', disposition: 'inline'
      else
        Rails.logger.error "Дефолтное изображение коллекции не найдено: #{default_image_path}"
        redirect_to asset_path('default_og_image.png')
      end
      
    rescue => e
      Rails.logger.error "Ошибка генерации дефолтного OG изображения коллекции: #{e.message}"
      redirect_to asset_path('default_og_image.png')
    end
  end
end 