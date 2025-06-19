class WelcomeController < ApplicationController
  include ProgramHelper
  def index
    @effects = Effect.includes(:user, :ratings).order(created_at: :desc).limit(3)
    @collections = Collection.all
  end

  def about
  end

  def search
    @query = params[:search]&.strip || ""
    
    if @query.present?
      # Поиск в моих эффектах (если пользователь авторизован)
      @my_effects = current_user ? search_effects(current_user.effects, @query) : []
      
      # Поиск во всех эффектах
      @all_effects = search_effects(Effect.approved, @query)
      
      # Поиск в моих коллекциях (если пользователь авторизован)
      @my_collections = current_user ? search_collections(current_user.collections, @query) : []
      
      # Поиск в подписках (если пользователь авторизован)
      @subscriptions = current_user ? search_collections(current_user.subscribed_collections, @query) : []
      
      # Поиск во всех коллекциях
      @all_collections = search_collections(Collection.where(status: 'Публичная'), @query)
    else
      @my_effects = []
      @all_effects = []
      @my_collections = []
      @subscriptions = []
      @all_collections = []
    end
  end

  private

  def search_effects(scope, query)
    scope.includes(:user, :ratings, :images)
         .where('LOWER(name) LIKE ? OR LOWER(description) LIKE ?', 
                "%#{query.downcase}%", "%#{query.downcase}%")
         .limit(20)
  end

  def search_collections(scope, query)
    scope.includes(:user, :effects, :images)
         .where('LOWER(name) LIKE ? OR LOWER(description) LIKE ?', 
                "%#{query.downcase}%", "%#{query.downcase}%")
         .limit(20)
  end
end
