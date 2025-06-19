class Api::V1::CollectionsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :find_user_collection, only: [:update_status, :destroy, :add_effect, :remove_effect, :add_link, :update_link, :remove_link, :add_image, :update_image, :remove_image]

  def index
    @collections = Collection.includes(:ratings, :effects, :links, :images).all
    render json: @collections.as_json(
      only: [:id, :name, :description, :status, :user_id],
      include: {
        effects: { only: [:id, :name, :img, :description, :speed, :platform, :manual, :created_at], methods: [:programs_with_versions] },
        links: { only: [:id, :path] },
        images: { only: [:id, :file, :title], methods: [:image_url] }
      }
    )
  end

  def my_collections
    @collections = current_user.collections.includes(:ratings, :effects, :links, :images)
    @favorites = current_user.favorites.includes(:effect)
    
    render json: {
      collections: @collections.as_json(
        only: [:id, :name, :description, :status, :user_id, :created_at, :updated_at],
        include: {
          effects: { only: [:id, :name, :img, :description, :created_at] },
          links: { only: [:id, :path, :title] },
          images: { only: [:id, :file, :title, :image_type], methods: [:image_url] }
        }
      ),
      favorites: @favorites.as_json(
        only: [:id, :created_at],
        include: {
          effect: {
            only: [:id, :name, :img, :description, :speed, :platform, :created_at],
            methods: [:programs_with_versions, :category_list, :task_list, :average_rating, :before_image, :after_image]
          }
        }
      )
    }
  end

  def show
    @collection = Collection.includes(:ratings, :effects, :links, :images).find(params[:id])
    render json: @collection.as_json(
      only: [:id, :name, :description, :status, :user_id],
      include: {
        effects: { only: [:id, :name, :img, :description, :speed, :platform, :manual, :created_at], methods: [:programs_with_versions] },
        links: { only: [:id, :path] },
        images: { only: [:id, :file, :title], methods: [:image_url] }
      }
    )
  end

  def create
    collection = current_user.collections.new(collection_params)
  
    if params[:links].present?
      if params[:links].is_a?(Array)
        params[:links].each do |link_params|
          collection.links.build(path: link_params[:path])
        end
      else
        collection.links.build(path: params[:links][:path])
      end
    end
    

    if params[:images].present?
      collection.images.build(
        file: params[:images][:file],
        title: params[:images][:title],
        image_type: params[:images][:image_type],
        imageable: collection
      )
    end
  
    if collection.save
      render json: { 
        message: 'Коллекция успешно создана', 
        collection: collection.as_json(
          include: {
            links: { only: [:id, :path] },
            images: { only: [:id, :file, :title, :image_type], methods: [:image_url] }
          }
        )
      }, status: :created
    else
      render json: { error: collection.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    collection_name = @collection.name
    
    if @collection.destroy
      render json: { 
        message: "Коллекция '#{collection_name}' успешно удалена" 
      }, status: :ok
    else
      render json: { 
        error: 'Ошибка при удалении коллекции',
        errors: @collection.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
   
  def update_status
    if @collection.update(status: params[:status])
      render json: { 
        message: 'Статус коллекции обновлен', 
        collection: @collection.as_json(
          include: {
            links: { only: [:id, :path] },
            images: { only: [:id, :file, :title], methods: [:image_url] }
          }
        )
      }, status: :ok
    else
      render json: { error: 'Ошибка обновления статуса коллекции' }, status: :unprocessable_entity
    end
  end

  # Методы для управления эффектами
  def add_effect
    effect = Effect.find_by(id: params[:effect_id])
    
    unless effect
      return render json: { error: 'Эффект не найден' }, status: :not_found
    end

    if @collection.effects.include?(effect)
      return render json: { error: 'Эффект уже добавлен в коллекцию' }, status: :unprocessable_entity
    end

    @collection.effects << effect
    render json: { 
      message: 'Эффект добавлен в коллекцию',
      collection: collection_with_includes
    }, status: :ok
  end

  def remove_effect
    effect = @collection.effects.find_by(id: params[:effect_id])
    
    unless effect
      return render json: { error: 'Эффект не найден в коллекции' }, status: :not_found
    end

    @collection.effects.delete(effect)
    render json: { 
      message: 'Эффект удален из коллекции',
      collection: collection_with_includes
    }, status: :ok
  end

  # Методы для управления ссылками
  def add_link
    link = Link.create(link_params)
    
    if link.persisted?
      @collection.links << link
      render json: { 
        message: 'Ссылка добавлена в коллекцию',
        collection: collection_with_includes
      }, status: :ok
    else
      render json: { error: link.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_link
    link = @collection.links.find_by(id: params[:link_id])
    
    unless link
      return render json: { success: false, error: 'Ссылка не найдена в коллекции' }, status: :not_found
    end

    if link.update(link_params)
      render json: { 
        success: true,
        message: 'Ссылка обновлена'
      }, status: :ok
    else
      render json: { success: false, error: link.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def remove_link
    link = @collection.links.find_by(id: params[:link_id])
    
    unless link
      return render json: { error: 'Ссылка не найдена в коллекции' }, status: :not_found
    end

    @collection.links.delete(link)
    link.destroy if link.collections.empty? # Удаляем ссылку если она больше не используется
    render json: { 
      message: 'Ссылка удалена из коллекции',
      collection: collection_with_includes
    }, status: :ok
  end

  # Методы для управления изображениями
  def add_image
    image = Image.create(image_params.merge(imageable: @collection))
    
    if image.persisted?
      # Добавляем изображение в коллекцию через промежуточную таблицу
      CollectionImage.create!(collection: @collection, image: image)
      render json: { 
        message: 'Изображение добавлено в коллекцию',
        collection: collection_with_includes
      }, status: :ok
    else
      render json: { error: image.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_image
    image = @collection.images.find_by(id: params[:image_id])
    
    unless image
      return render json: { error: 'Изображение не найдено в коллекции' }, status: :not_found
    end

    update_params = image_update_params
    if update_params.present?
      if image.update(update_params)
        render json: { 
          message: 'Изображение обновлено',
          collection: collection_with_includes
        }, status: :ok
      else
        render json: { error: image.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Нет данных для обновления' }, status: :unprocessable_entity
    end
  end

  def remove_image
    image = @collection.images.find_by(id: params[:image_id])
    
    unless image
      return render json: { error: 'Изображение не найдено в коллекции' }, status: :not_found
    end

    @collection.images.delete(image)
    image.destroy # Удаляем изображение
    render json: { 
      message: 'Изображение удалено из коллекции',
      collection: collection_with_includes
    }, status: :ok
  end

  private

  def collection_params
    params.require(:collection).permit(
      :name, 
      :description, 
      :status, 
      :user_id,
      link_ids: [],
      image_ids: []
    )
  end

  def link_params
    # Для прямых параметров (без обертки link)
    if params[:title].present? || params[:path].present? || params[:description].present?
      {
        title: params[:title],
        path: params[:path],
        description: params[:description]
      }.compact
    else
      # Для параметров с оберткой link
      params.require(:link).permit(:path, :title, :description)
    end
  end

  def image_params
    # Для multipart form data
    if params[:file].present?
      {
        file: params[:file],
        title: params[:title] || 'Без названия',
        image_type: params[:image_type] || 'description'
      }
    else
      # Для JSON данных
      params.require(:image).permit(:file, :title, :image_type)
    end
  end

  def image_update_params
    # Для обновления изображения
    if params[:file].present? || params[:title].present? || params[:image_type].present?
      update_hash = {}
      update_hash[:file] = params[:file] if params[:file].present?
      update_hash[:title] = params[:title] if params[:title].present?
      update_hash[:image_type] = params[:image_type] if params[:image_type].present?
      update_hash
    else
      # Для JSON данных при обновлении
      params.permit(:file, :title, :image_type).reject { |k, v| v.blank? }
    end
  end

  def find_user_collection
    @collection = current_user.collections.find_by(id: params[:id])
    
    unless @collection
      render json: { error: 'Коллекция не найдена или доступ запрещен' }, status: :not_found
    end
  end

  def collection_with_includes
    @collection.as_json(
      only: [:id, :name, :description, :status, :user_id],
      include: {
        effects: { only: [:id, :name, :img, :description, :speed, :platform, :manual, :created_at], methods: [:programs_with_versions] },
        links: { only: [:id, :path, :title] },
        images: { only: [:id, :file, :title, :image_type], methods: [:image_url] }
      }
    )
  end
end
