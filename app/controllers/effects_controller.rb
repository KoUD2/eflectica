class EffectsController < ApplicationController
  include ProgramHelper
  # load_and_authorize_resource
  # before_action :authenticate_user!
  before_action :authenticate_user!, only: [:save_preferences]
  before_action :set_effect, only: [:show, :edit, :update, :destroy, :approve, :reject]

  # GET /effects or /effects.json
  def index
    @top_effects = Effect.limit(5)
    @effects = Effect.search(params[:search]).page(params[:page]).per(12)
    @services = YAML.load_file(Rails.root.join("config/services/app.yml"))["services"]

    @collections = Collection.includes(effects: :images).limit(3)

    @categories = ["photoProcessing", "3dGrafics", "motion", "illustration", "animation", "uiux", "videoProcessing", "vfx", "gamedev", "arvr"]

    # Проверяем, настроена ли лента у пользователя
    @feed_configured = current_user && (current_user.preferred_categories.any? || current_user.preferred_programs.any?)
    
    # Передаем текущие предпочтения для отображения в модалке
    @user_categories = current_user&.preferred_categories&.pluck(:name) || []
    @user_programs = current_user&.preferred_programs&.pluck(:name) || []
    
    Rails.logger.info "=== MODAL DATA DEBUG ==="
    Rails.logger.info "@user_categories: #{@user_categories.inspect}"
    Rails.logger.info "@user_programs: #{@user_programs.inspect}"
    Rails.logger.info "@user_categories.to_json: #{@user_categories.to_json}"
    Rails.logger.info "@user_programs.to_json: #{@user_programs.to_json}"
    
    Rails.logger.info "=== FEED DEBUG ==="
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "User categories: #{@user_categories}"
    Rails.logger.info "User programs: #{@user_programs}"
    Rails.logger.info "Feed configured: #{@feed_configured}"
    
    if @feed_configured
      @filtered_effects = current_user.personalized_feed.limit(9)
      @collectionsFeed = Collection.joins(effects: :collection_effects)
        .where(effects: { id: @filtered_effects.ids })
        .distinct
        .limit(3)
    else
      # Получаем эффекты, связанные с photoshop или lightroom через новую систему связей
      photoshop_program = EffectProgram.find_by(name: 'photoshop')
      lightroom_program = EffectProgram.find_by(name: 'lightroom')
      
      program_ids = [photoshop_program&.id, lightroom_program&.id].compact
      
      if program_ids.any?
        effect_ids = EffectEffectProgram.where(effect_program_id: program_ids).pluck(:effect_id)
        @collectionsFeed = Collection.joins(:effects)
          .where(effects: { id: effect_ids })
          .distinct
          .limit(3)
        @filtered_effects = Effect.where(id: effect_ids)
      else
        @collectionsFeed = Collection.limit(3)
        @filtered_effects = Effect.none
      end
    end
  
    if params[:programs].present?
      selected_programs = params[:programs]
      @effects = @effects.select do |effect|
        (selected_programs & effect.programs_list).any?
      end
    end
  
    respond_to do |format|
      format.html
      format.js
    end
  end

  def categorie
    @category = params[:category]
    
    # Ищем эффекты как в тегах, так и в связанных таблицах
    effects_from_tags = Effect.includes(:ratings).tagged_with(@category, on: :categories)
    effects_from_relations = Effect.includes(:ratings)
      .joins(:effect_effect_categories)
      .joins('JOIN effect_categories ON effect_categories.id = effect_effect_categories.effect_category_id')
      .where('effect_categories.name = ?', @category)
    
    # Объединяем результаты и убираем дубликаты
    @effects = (effects_from_tags + effects_from_relations).uniq
    
    # Если передан collection_id, то мы в режиме выбора эффектов для коллекции
    @collection_id = params[:collection_id]
    if @collection_id
      @collection = Collection.find(@collection_id) 
      @collection_effect_ids = @collection.effect_ids
    end
    
    # Получаем уникальные задачи для эффектов в этой категории
    @tasks = []
    @effects.each do |effect|
      @tasks.concat(effect.task_list)
    end
    @tasks = @tasks.uniq.compact.reject(&:blank?)
    
    # Получаем уникальные программы для эффектов в этой категории
    @programs = []
    @effects.each do |effect|
      @programs.concat(effect.programs_list)
    end
    @programs = @programs.uniq.compact.reject(&:blank?)
    
    Rails.logger.info "=== CATEGORY DEBUG ==="
    Rails.logger.info "Category: #{@category}"
    Rails.logger.info "Effects from tags: #{effects_from_tags.count}"
    Rails.logger.info "Effects from relations: #{effects_from_relations.count}"
    Rails.logger.info "Total effects count: #{@effects.count}"
    Rails.logger.info "Collection ID: #{@collection_id}"
    Rails.logger.info "Collection effect IDs: #{@collection_effect_ids.inspect}" if @collection_effect_ids
    Rails.logger.info "Tasks found: #{@tasks.inspect}"
    Rails.logger.info "Programs found: #{@programs.inspect}"
    
    # Дополнительная отладка - покажем все категории в системе
    all_effect_categories = EffectCategory.pluck(:name)
    Rails.logger.info "All effect categories in DB: #{all_effect_categories.inspect}"
  end

  def categories
    @effects = Effect.includes(:images, :taggings)
    
    # Получаем категории как из тегов, так и из связанных таблиц
    categories_from_tags = ActsAsTaggableOn::Tag
      .for_context(:categories)
      .distinct
      .pluck(:name)
    categories_from_relations = EffectCategory.pluck(:name)
    
    # Объединяем и убираем дубликаты
    @categories = (categories_from_tags + categories_from_relations).uniq.sort
    
    @programs = YAML.load_file(Rails.root.join("config/services/app.yml"))["programs"]
    
    # Если передан collection_id, то мы в режиме выбора эффектов для коллекции
    @collection_id = params[:collection_id]
    if @collection_id
      @collection = Collection.find(@collection_id) 
      @collection_effect_ids = @collection.effect_ids
    end
  end

  def trending
    # Получаем трендовые эффекты (по количеству лайков за последний месяц)
    trending_effect_ids = Effect.joins(:ratings)
      .where(ratings: { created_at: 1.month.ago..Time.current, number: 4..5 })
      .group('effects.id')
      .order('COUNT(ratings.id) DESC')
      .limit(50)
      .pluck(:id)
    
    if trending_effect_ids.any?
      @effects = Effect.where(id: trending_effect_ids)
        .includes(:images, :ratings)
        .order(Arel.sql("array_position(ARRAY[#{trending_effect_ids.join(',')}], effects.id)"))
    else
      # Если нет эффектов с высокими рейтингами, берем самые новые
      @effects = Effect.order(created_at: :desc).includes(:images, :ratings).limit(50)
    end
    
    # Получаем уникальные задачи для трендовых эффектов
    @tasks = []
    @effects.each do |effect|
      @tasks.concat(effect.task_list)
    end
    @tasks = @tasks.uniq.compact.reject(&:blank?)
    
    # Получаем уникальные программы для трендовых эффектов
    @programs = []
    @effects.each do |effect|
      @programs.concat(effect.programs_list)
    end
    @programs = @programs.uniq.compact.reject(&:blank?)
  end

  def similar
    # Получаем похожие эффекты (отсортированные по популярности)
    @effects = Effect.left_joins(:ratings)
      .group('effects.id')
      .order('COUNT(ratings.id) DESC, effects.created_at DESC')
      .includes(:images, :ratings)
      .limit(100)
    
    # Получаем уникальные задачи для похожих эффектов
    @tasks = []
    @effects.each do |effect|
      @tasks.concat(effect.task_list)
    end
    @tasks = @tasks.uniq.compact.reject(&:blank?)
    
    # Получаем уникальные программы для похожих эффектов
    @programs = []
    @effects.each do |effect|
      @programs.concat(effect.programs_list)
    end
    @programs = @programs.uniq.compact.reject(&:blank?)
    
    @page_title = "Похожие эффекты"
  end

  def by_tag
    @effects = Effect.tagged_with(params[:tag])
    render :index
  end

  # GET /effects/1 or /effects/1.json
  def show
    @effect = Effect.includes(comments: { user: :ratings }).find(params[:id])
    @effects = Effect.where.not(id: @effect.id).limit(4)
    @user_collections = current_user.collections if current_user
    @effect_collections = current_user ? @effect.collections.where(user: current_user).pluck(:id) : []
    @comment = Comment.new
  rescue ActiveRecord::RecordNotFound
    redirect_to "/404" and return
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
    # Проверяем, что переданы обязательные поля
    if params[:name].blank? && params[:description].blank? && params[:image_before].blank?
      Rails.logger.info "Effect creation cancelled: empty required fields"
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: ["Заполните обязательные поля"] }, status: :unprocessable_entity }
      end
      return
    end

    @effect = Effect.new(effect_params)
    @effect.user = current_user
    
    # Устанавливаем значения по умолчанию для обязательных полей
    @effect.speed = 5 if @effect.speed.blank?
    @effect.img = params[:image_before] if @effect.img.blank? && params[:image_before]

    respond_to do |format|
      if @effect.save
        attach_images
        attach_programs
        attach_tasks
        attach_categories
        format.html { redirect_to @effect, notice: "Эффект был успешно создан" }
        format.json { render :show, status: :created, location: @effect }
      else
        Rails.logger.error "Effect creation failed: #{@effect.errors.full_messages}"
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

  def save_preferences
    Rails.logger.info "=== SAVE PREFERENCES DEBUG ==="
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "Params categories: #{params[:categories]}"
    Rails.logger.info "Params programs: #{params[:programs]}"
    
    if current_user
      # Получаем текущие предпочтения
      current_categories = current_user.preferred_categories.pluck(:name)
      current_programs = current_user.preferred_programs.pluck(:name)
      
      new_categories = params[:categories] || []
      new_programs = params[:programs] || []
      
      # Обновляем категории (добавляем новые, удаляем снятые)
      categories_to_add = new_categories - current_categories
      categories_to_remove = current_categories - new_categories
      
      Rails.logger.info "Categories to add: #{categories_to_add}"
      Rails.logger.info "Categories to remove: #{categories_to_remove}"
      
      # Добавляем новые категории
      categories_to_add.each do |category_name|
        category = EffectCategory.find_or_create_by(name: category_name)
        current_user.user_effect_categories.create(effect_category: category)
        Rails.logger.info "Added category preference: #{category_name}"
      end
      
      # Удаляем снятые категории
      categories_to_remove.each do |category_name|
        category = EffectCategory.find_by(name: category_name)
        if category
          current_user.user_effect_categories.find_by(effect_category: category)&.destroy
          Rails.logger.info "Removed category preference: #{category_name}"
        end
      end
      
      # Обновляем программы (добавляем новые, удаляем снятые)
      programs_to_add = new_programs - current_programs
      programs_to_remove = current_programs - new_programs
      
      Rails.logger.info "Programs to add: #{programs_to_add}"
      Rails.logger.info "Programs to remove: #{programs_to_remove}"
      
      # Добавляем новые программы
      programs_to_add.each do |program_name|
        program = EffectProgram.find_or_create_by(name: program_name)
        current_user.user_effect_programs.create(effect_program: program)
        Rails.logger.info "Added program preference: #{program_name}"
      end
      
      # Удаляем снятые программы
      programs_to_remove.each do |program_name|
        program = EffectProgram.find_by(name: program_name)
        if program
          current_user.user_effect_programs.find_by(effect_program: program)&.destroy
          Rails.logger.info "Removed program preference: #{program_name}"
        end
      end
      
      Rails.logger.info "Preferences updated successfully"
      render json: { status: 'success', message: 'Предпочтения обновлены' }
    else
      Rails.logger.error "User not authenticated"
      render json: { status: 'error', message: 'Необходимо войти в систему' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_effect
      @effect = Effect.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to "/404" and return
    end

    def set_devise_resource
      self.resource = User.new
      self.resource_name = :user
      self.devise_mapping = Devise.mappings[:user]
    end

    # Only allow a list of trusted parameters through.
    def effect_params
      params.permit(:name, :description, :manual, :platform, :category_list, :link_to, :img, :speed)
    end

    def set_authorization_flag
      @author_or_admin = current_user && current_user.is_admin?
    end
    

    def attach_images
      if params[:image_before]
        @effect.images.create(
          file: params[:image_before],
          image_type: 'before'
        )
      end
      
      if params[:image_after]
        @effect.images.create(
          file: params[:image_after],
          image_type: 'after'
        )
      end
    end

    def attach_programs
      if params[:effect] && params[:effect][:effect_programs_attributes]
        params[:effect][:effect_programs_attributes].each do |key, program_data|
          next if program_data[:name].blank?
          
          # Найти или создать программу
          effect_program = EffectProgram.find_or_create_by(name: program_data[:name])
          effect_program.update(version: program_data[:version]) if program_data[:version].present?
          
          # Создать связь между эффектом и программой
          @effect.effect_effect_programs.create(effect_program: effect_program)
        end
      end
    end

    def attach_tasks
      # Собираем задачи из параметров вида task_list_*
      selected_tasks = []
      Rails.logger.info "=== ATTACH TASKS DEBUG ==="
      Rails.logger.info "All params: #{params.keys.grep(/task_list/)}"
      
      params.each do |key, value|
        if key.start_with?('task_list_') && value.present?
          task_name = value
          selected_tasks << task_name
          Rails.logger.info "Found task: #{key} = #{value}"
        end
      end
      
      Rails.logger.info "Selected tasks: #{selected_tasks.inspect}"
      
      # Создаем связи с задачами
      selected_tasks.each do |task_name|
        effect_task = EffectTask.find_or_create_by(name: task_name)
        relation = @effect.effect_effect_tasks.create(effect_task: effect_task)
        Rails.logger.info "Created task relation: #{relation.inspect}, errors: #{relation.errors.full_messages}"
      end
      
      # Проверяем что сохранилось
      @effect.reload
      Rails.logger.info "Effect tasks after save: #{@effect.task_list.inspect}"
      Rails.logger.info "=== END ATTACH TASKS DEBUG ==="
    end

    def attach_categories
      # Сохраняем категорию из параметра category_list
      if params[:category_list].present?
        Rails.logger.info "=== ATTACH CATEGORIES DEBUG ==="
        Rails.logger.info "Category from params: #{params[:category_list]}"
        
        effect_category = EffectCategory.find_or_create_by(name: params[:category_list])
        relation = @effect.effect_effect_categories.create(effect_category: effect_category)
        
        Rails.logger.info "Created effect_category: #{effect_category.inspect}"
        Rails.logger.info "Created relation: #{relation.inspect}, errors: #{relation.errors.full_messages}"
        
        # Проверяем что сохранилось
        @effect.reload
        Rails.logger.info "Effect categories after save: #{@effect.category_list.inspect}"
        Rails.logger.info "=== END ATTACH CATEGORIES DEBUG ==="
      end
    end
end
