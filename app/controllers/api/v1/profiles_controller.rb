class Api::V1::ProfilesController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:show]
  
  def show
    @user = User.find(params[:id])
    render json: @user.as_json(
      only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar],
      methods: [:favorites]
    )
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Пользователь не найден" }, status: :not_found
  end
  
  def me
    render json: current_user.as_json(
      only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar],
      methods: [:favorites]
    )
  end

  def update
    update_params = profile_params
    
    if current_user.update(update_params)
      render json: {
        message: "Профиль успешно обновлён",
        user: current_user.as_json(
          only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar]
        )
      }, status: :ok
    else
      render json: {
        error: "Ошибка при обновлении профиля",
        errors: current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.destroy
      render json: { message: "Профиль успешно удалён" }, status: :ok
    else
      render json: { error: "Ошибка при удалении профиля" }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    # Для multipart form data (с файлом аватара)
    if request.content_type&.include?('multipart/form-data')
      permitted_params = {}
      permitted_params[:username] = params[:username] if params[:username].present?
      permitted_params[:name] = params[:name] if params[:name].present?
      permitted_params[:bio] = params[:bio] if params[:bio].present?
      permitted_params[:contact] = params[:contact] if params[:contact].present?
      permitted_params[:portfolio] = params[:portfolio] if params[:portfolio].present?
      permitted_params[:avatar] = params[:avatar] if params[:avatar].present?
      permitted_params
    else
      # Для JSON данных
      params.require(:profile).permit(
        :username,
        :name,
        :bio,
        :contact,
        :portfolio,
        :avatar
      )
    end
  end
end 