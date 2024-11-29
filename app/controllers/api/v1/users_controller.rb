class Api::V1::UsersController < ApplicationController
  def index
    @users = User.includes(favorites: :effect).all
  end

  def show
    @user = User.includes(favorites: :effect).find(params[:id])
  end
end
