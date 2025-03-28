class ProfilesController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = current_user
  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path(current_user), notice: "Профиль обновлён"
    else
      render :edit
    end
  end

  def destroy
    current_user.destroy
    redirect_to root_path, notice: 'Профиль успешно удалён'
  end

  private

  def user_params
    params.require(:user).permit(
      :username,
      :name,
      :bio,
      :avatar,
      :contact
    )
  end
  
end
