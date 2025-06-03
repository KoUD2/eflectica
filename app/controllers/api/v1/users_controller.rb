class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:me]
  
  def index
    @users = User.all
    render json: @users.as_json(
      only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar]
    )
  end

  def show
    @user = User.find(params[:id])
    render json: @user.as_json(
      only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar]
    )
  end
  
  def me
    render json: current_user.as_json(
      only: [:id, :email, :username, :name, :bio, :contact, :portfolio, :is_admin, :avatar]
    )
  end
end
