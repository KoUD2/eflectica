class Api::V1::EffectsController < ApplicationController
  def index
    @effects = Effect.includes(:comments, :ratings).all
  end

  def show
    @effect = Effect.includes(:comments, :ratings).find(params[:id])
  end
end
