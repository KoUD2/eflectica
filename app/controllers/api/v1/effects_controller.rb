class Api::V1::EffectsController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:my_effects, :destroy]
  before_action :find_user_effect, only: [:destroy]

  def index
    @effects = Effect.includes(:images, :comments, :ratings).all
    render json: @effects.as_json(
      only: [:id, :name, :img, :description, :speed, :platform, :manual, :programs, :program_version],
      methods: [:category_list, :task_list, :average_rating, :before_image, :after_image]
    )
  end

  def show
    @effect = Effect.includes(:images, :comments, :ratings).find(params[:id])
    render json: @effect.as_json(
      only: [:id, :name, :img, :description, :speed, :platform, :manual, :programs, :program_version],
      methods: [:category_list, :task_list, :average_rating, :before_image, :after_image]
    )
  end

  def my_effects
    @effects = current_user.effects.includes(:images, :comments, :ratings)
    render json: @effects.as_json(
      only: [:id, :name, :img, :description, :speed, :platform, :manual, :programs, :program_version, :is_secure, :created_at, :updated_at],
      methods: [:category_list, :task_list, :average_rating, :before_image, :after_image],
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
