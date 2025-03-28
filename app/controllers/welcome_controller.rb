class WelcomeController < ApplicationController
  def index
    @effects = Effect.includes(:user, :ratings).order(created_at: :desc).limit(3)
    @collections = Collection.all
  end

  def about
  end
end
