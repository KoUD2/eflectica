class CollectionsController < ApplicationController
  load_and_authorize_resource except: [:index, :by_tag, :search, :trending, :similar, :new, :create, :show, :subscribe, :unsubscribe]
  before_action :authenticate_user!
  before_action :set_collection, only: %i[ show edit update destroy bulk_add_effects bulk_update_effects add_link ]
  before_action :load_and_authorize_collection, only: %i[ subscribe unsubscribe ]

  # GET /collections or /collections.json
  def index
    @subscribed_collections = current_user.subscribed_collections if user_signed_in?
    @collections = Collection.where.not(user_id: current_user.id)
                             .where(status: 'public')
                             .order(created_at: :desc)
    
    # Получаем трендовые коллекции для отображения на странице
    trending_collection_ids = Collection.joins(:sub_collections)
      .where(sub_collections: { created_at: 1.month.ago..Time.current })
      .where(status: 'public')
      .group('collections.id')
      .order('COUNT(sub_collections.id) DESC')
      .limit(3)
      .pluck(:id)
    
    if trending_collection_ids.any?
      @trending_collections = Collection.where(id: trending_collection_ids)
        .includes(:effects, :user)
        .order(Arel.sql("array_position(ARRAY[#{trending_collection_ids.join(',')}], collections.id)"))
    else
      # Если нет коллекций с подписчиками, берем самые новые публичные
      @trending_collections = Collection.where(status: 'public')
        .order(created_at: :desc)
        .includes(:effects, :user)
        .limit(3)
    end
  end

  def by_tag
    @collections = Collection.tagged_with(params[:tag])
    render :index
  end

  def search
    query = params[:q]&.strip&.downcase
    Rails.logger.info "=== COLLECTION SEARCH DEBUG ==="
    Rails.logger.info "Query: #{query}"
    Rails.logger.info "Current user: #{current_user&.id}"
    
    if query.present?
      # Ищем коллекции по названию и описанию (исключая коллекции текущего пользователя)
      other_collections = Collection.where.not(user_id: current_user&.id)
        .where(status: 'public')
        .where("LOWER(name) ILIKE ? OR LOWER(description) ILIKE ?", "%#{query}%", "%#{query}%")
        .limit(10)
      
      Rails.logger.info "Found collections: #{other_collections.count}"
      Rails.logger.info "Collection names: #{other_collections.pluck(:name)}"
      
      # Формируем HTML для каждой коллекции
      collections_html = other_collections.map do |collection|
        {
          html: render_to_string(
            partial: 'collections/collection',
            locals: { 
              collection: collection, 
              css_classes: { header: "A", text: "A" } 
            },
            formats: [:html]
          )
        }
      end
      
      render json: { other_collections: collections_html }
    else
      render json: { other_collections: [] }
    end
  end

  def trending
    # Получаем трендовые коллекции (по количеству подписчиков за последний месяц)
    trending_collection_ids = Collection.joins(:sub_collections)
      .where(sub_collections: { created_at: 1.month.ago..Time.current })
      .where(status: 'public')
      .group('collections.id')
      .order('COUNT(sub_collections.id) DESC')
      .limit(50)
      .pluck(:id)
    
    if trending_collection_ids.any?
      @collections = Collection.where(id: trending_collection_ids)
        .includes(:effects, :user)
        .order(Arel.sql("array_position(ARRAY[#{trending_collection_ids.join(',')}], collections.id)"))
    else
      # Если нет коллекций с подписчиками, берем самые новые публичные
      @collections = Collection.where(status: 'public')
        .order(created_at: :desc)
        .includes(:effects, :user)
        .limit(50)
    end
  end

  def similar
    # Получаем похожие коллекции (публичные коллекции, отсортированные по популярности)
    @collections = Collection.where(status: 'public')
      .where.not(user_id: current_user&.id)
      .left_joins(:sub_collections)
      .group('collections.id')
      .order('COUNT(sub_collections.id) DESC, collections.created_at DESC')
      .includes(:effects, :user)
      .limit(100)
    
    @page_title = "Похожие коллекции"
  end

  # GET /collections/1 or /collections/1.json
  def show
    @collection = Collection.find(params[:id])
    @programs = helpers.programs
  end

  # GET /collections/new
  def new
    render layout: 'application'
    @collection = Collection.new
  end

  def subscribe
    begin
      @collection = Collection.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render 'errors/not_found', status: 404, layout: 'errors' and return
    end
    
    if @collection.status != 'private' && !current_user.subscribed_to?(@collection)
      subscription = SubCollection.new(user: current_user, collection: @collection)
      
      if subscription.save
        respond_to do |format|
          format.html { redirect_to @collection }
          format.json { 
            html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection, is_collection_context: is_collection_card_context? }, formats: [:html])
            render json: { status: 'success', html: html } 
          }
        end
      else
        respond_to do |format|
          format.html { redirect_to @collection, alert: 'Не удалось подписаться на коллекцию' }
          format.json { 
            html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection, is_collection_context: is_collection_card_context? }, formats: [:html])
            render json: { status: 'error', html: html }, status: :unprocessable_entity
          }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @collection, alert: 'Вы не можете подписаться на эту коллекцию' }
        format.json { 
          html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection, is_collection_context: is_collection_card_context? }, formats: [:html])
          render json: { status: 'error', html: html }, status: :unprocessable_entity
        }
      end
    end
  end  

  def unsubscribe
    begin
      @collection = Collection.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render 'errors/not_found', status: 404, layout: 'errors' and return
    end
    
    subscription = current_user.sub_collections.find_by(collection: @collection)
    
    if subscription&.destroy
      respond_to do |format|
        format.html { redirect_to @collection }
        format.json { 
          html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection, is_collection_context: is_collection_card_context? }, formats: [:html])
          render json: { status: 'success', html: html }
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to @collection, alert: 'Не удалось отписаться от коллекции' }
        format.json { 
          html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection, is_collection_context: is_collection_card_context? }, formats: [:html])
          render json: { status: 'error', html: html }, status: :unprocessable_entity
        }
      end
    end
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections or /collections.json
  def create
    @collection = current_user.collections.new(collection_params)

    if @collection.save
      flash[:notice] = "Коллекция успешно создана!"
      # Если создание происходит с страницы эффекта, остаемся на той же странице
      if request.referer&.include?('/effects/')
        redirect_back(fallback_location: news_feeds_path)
      else
        redirect_to news_feeds_path
      end
    else
      flash[:alert] = "Не удалось создать коллекцию. Проверьте введённые данные."
      redirect_back(fallback_location: collections_path)
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy!

    respond_to do |format|
      format.html { redirect_to collections_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /collections/1/effects/bulk_add
  def bulk_add_effects
    effect_ids = params[:effect_ids]
    
    if effect_ids.blank?
      render json: { success: false, error: 'Не выбраны эффекты' }, status: :bad_request
      return
    end
    
    added_count = 0
    errors = []
    
    effect_ids.each do |effect_id|
      effect = Effect.find_by(id: effect_id)
      
      if effect.nil?
        errors << "Эффект с ID #{effect_id} не найден"
        next
      end
      
      # Проверяем, не добавлен ли уже этот эффект в коллекцию
      if @collection.effects.include?(effect)
        errors << "Эффект \"#{effect.name}\" уже есть в коллекции"
        next
      end
      
      collection_effect = CollectionEffect.new(collection: @collection, effect: effect)
      
      if collection_effect.save
        added_count += 1
      else
        errors << "Не удалось добавить эффект \"#{effect.name}\": #{collection_effect.errors.full_messages.join(', ')}"
      end
    end
    
    if added_count > 0
      render json: { 
        success: true, 
        message: "Добавлено #{added_count} эффектов в коллекцию",
        added_count: added_count,
        errors: errors.any? ? errors : nil
      }
    else
      render json: { 
        success: false, 
        error: "Не удалось добавить ни одного эффекта",
        errors: errors
      }, status: :unprocessable_entity
    end
  end

  # POST /collections/1/effects/bulk_update
  def bulk_update_effects
    add_effect_ids = params[:add_effect_ids] || []
    remove_effect_ids = params[:remove_effect_ids] || []
    
    if add_effect_ids.blank? && remove_effect_ids.blank?
      render json: { success: false, error: 'Нет изменений для сохранения' }, status: :bad_request
      return
    end
    
    added_count = 0
    removed_count = 0
    errors = []
    
    # Добавляем эффекты
    add_effect_ids.each do |effect_id|
      effect = Effect.find_by(id: effect_id)
      
      if effect.nil?
        errors << "Эффект с ID #{effect_id} не найден"
        next
      end
      
      # Проверяем, не добавлен ли уже этот эффект в коллекцию
      if @collection.effects.include?(effect)
        next # Пропускаем, уже есть
      end
      
      collection_effect = CollectionEffect.new(collection: @collection, effect: effect)
      
      if collection_effect.save
        added_count += 1
      else
        errors << "Не удалось добавить эффект \"#{effect.name}\": #{collection_effect.errors.full_messages.join(', ')}"
      end
    end
    
    # Удаляем эффекты
    remove_effect_ids.each do |effect_id|
      effect = Effect.find_by(id: effect_id)
      
      if effect.nil?
        errors << "Эффект с ID #{effect_id} не найден"
        next
      end
      
      collection_effect = @collection.collection_effects.find_by(effect: effect)
      
      if collection_effect&.destroy
        removed_count += 1
      else
        errors << "Не удалось удалить эффект \"#{effect.name}\""
      end
    end
    
    render json: { 
      success: true, 
      message: "Изменения сохранены",
      added_count: added_count,
      removed_count: removed_count,
      errors: errors.any? ? errors : nil
    }
  end

  # POST /collections/1/add_link
  def add_link
    name = params[:name]
    notes = params[:notes]
    url = params[:url]
    
    Rails.logger.info "=== ADD LINK DEBUG ==="
    Rails.logger.info "Collection ID: #{@collection.id}"
    Rails.logger.info "Name: #{name}"
    Rails.logger.info "Notes: #{notes}"
    Rails.logger.info "URL: #{url}"
    
    if name.blank? || url.blank?
      render json: { 
        success: false, 
        error: "Название и URL должны быть заполнены" 
      }, status: :bad_request
      return
    end
    
    begin
      ActiveRecord::Base.transaction do
        # Создаем ссылку
        link = Link.create!(
          title: name,
          path: url,
          description: notes
        )
        
        # Привязываем к коллекции
        @collection.collection_links.create!(link: link)
        
        Rails.logger.info "Link created successfully with ID: #{link.id}"
      end
      
      render json: { 
        success: true, 
        message: "Ссылка добавлена в коллекцию"
      }
    rescue => e
      Rails.logger.error "Add link error: #{e.message}"
      render json: { 
        success: false, 
        error: e.message 
      }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render 'errors/not_found', status: 404, layout: 'errors'
    end

    def load_and_authorize_collection
      @collection = Collection.find(params[:id])
      authorize! :read, @collection
    rescue ActiveRecord::RecordNotFound
      render 'errors/not_found', status: 404, layout: 'errors'
    rescue CanCan::AccessDenied
      render 'errors/forbidden', status: 403, layout: 'errors'
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name, :description, :status, :user_id)
    end

    def is_collection_card_context?
      # Проверяем, что запрос НЕ со страницы show коллекции
      referer = request.referer
      return false if referer.nil?
      
      # Если referrer содержит путь к странице коллекции /collection/ID, то это НЕ контекст карточки
      !referer.include?("/collection/#{@collection.id}")
    end

    def create_sample_collections
      # Создаем несколько тестовых коллекций
      sample_collections = [
        {
          name: "Лучшие эффекты для портретов",
          description: "Коллекция эффектов для обработки портретных фотографий",
          status: "public"
        },
        {
          name: "Эффекты для социальных сетей",
          description: "Стильные эффекты для Instagram и других социальных сетей",
          status: "public"
        },
        {
          name: "Винтажные фильтры",
          description: "Коллекция винтажных и ретро эффектов",
          status: "public"
        },
        {
          name: "Цветокоррекция",
          description: "Профессиональные пресеты для цветокоррекции",
          status: "public"
        },
        {
          name: "Черно-белые эффекты",
          description: "Элегантные монохромные эффекты",
          status: "public"
        }
      ]

      sample_collections.each do |collection_data|
        Collection.create!(
          name: collection_data[:name],
          description: collection_data[:description],
          status: collection_data[:status],
          user: User.first || current_user
        )
      end
    end
end
