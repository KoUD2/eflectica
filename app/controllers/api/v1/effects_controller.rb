class Api::V1::EffectsController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:my_effects, :destroy, :feed]
  before_action :find_user_effect, only: [:destroy]

  def index
    @effects = Effect.includes(:images, :ratings, :user, comments: :user).approved
    # Используем Jbuilder шаблон для единообразия
  end

  def show
    @effect = Effect.includes(:images, :ratings, :user, comments: :user).find(params[:id])
    # Используем Jbuilder шаблон для единообразия
  end

  def my_effects
    @effects = current_user.effects.includes(:images, :comments, :ratings, :user)
    render json: @effects.as_json(
      only: [:id, :name, :img, :description, :speed, :platform, :manual, :is_secure, :created_at, :updated_at],
      methods: [:category_list, :task_list, :programs_with_versions, :average_rating, :before_image, :after_image],
      include: {
        user: { only: [:id, :username, :avatar] }
      }
    )
  end

  def feed
    # Получаем предпочтения пользователя
    user_program_ids = current_user.user_effect_programs.pluck(:effect_program_id)
    user_category_ids = current_user.user_effect_categories.pluck(:effect_category_id)
    
    # Если у пользователя нет предпочтений, возвращаем популярные эффекты
    if user_program_ids.empty? && user_category_ids.empty?
      # Сначала получаем ID эффектов с их рейтингами
      effect_ids_with_avg_rating = Effect.where(is_secure: "Одобрено")
                                          .where.not(user_id: current_user.id)
                                          .joins(:ratings)
                                          .group('effects.id')
                                          .order('AVG(ratings.number) DESC, effects.created_at DESC')
                                          .limit(20)
                                          .pluck(:id)
      
      # Затем загружаем эффекты с нужными ассоциациями
      @effects = Effect.includes(:images, :comments, :ratings, :user)
                       .where(id: effect_ids_with_avg_rating)
                       .order(Arel.sql("CASE effects.id #{effect_ids_with_avg_rating.map.with_index { |id, index| "WHEN #{id} THEN #{index}" }.join(' ')} END"))
    else
      # Строим запрос для поиска эффектов на основе предпочтений
      effect_ids_from_programs = []
      effect_ids_from_categories = []
      
      if user_program_ids.any?
        effect_ids_from_programs = EffectEffectProgram.where(effect_program_id: user_program_ids).pluck(:effect_id)
      end
      
      if user_category_ids.any?
        effect_ids_from_categories = EffectEffectCategory.where(effect_category_id: user_category_ids).pluck(:effect_id)
      end
      
      # Объединяем ID эффектов из предпочтений по программам и категориям
      effect_ids = (effect_ids_from_programs + effect_ids_from_categories).uniq
      
      @effects = Effect.includes(:images, :comments, :ratings, :user)
                       .where(id: effect_ids)
                       .where(is_secure: "Одобрено")
                       .where.not(user_id: current_user.id)
                       .order('effects.created_at DESC')
                       .limit(20)
    end
    
    render json: @effects.as_json(
      only: [:id, :name, :img, :description, :speed, :platform, :manual, :created_at],
      methods: [:category_list, :task_list, :programs_with_versions, :average_rating, :before_image, :after_image],
      include: {
        user: { only: [:id, :username, :avatar] }
      }
    )
  end

  def destroy
    effect_name = @effect.name
    
    # Удаляем связанные записи перед удалением эффекта
    @effect.comments.destroy_all
    @effect.ratings.destroy_all
    @effect.collection_effects.destroy_all
    @effect.favorites.destroy_all
    
    if @effect.destroy
      render json: { 
        message: "Эффект '#{effect_name}' успешно удален" 
      }, status: :ok
    else
      render json: { 
        error: 'Ошибка при удалении эффекта',
        errors: @effect.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  private

  def find_user_effect
    @effect = current_user.effects.find_by(id: params[:id])
    
    unless @effect
      render json: { error: 'Эффект не найден или доступ запрещен' }, status: :not_found
    end
  end
end
