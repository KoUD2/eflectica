class Api::V1::EffectsController < ApplicationController
  def index
    @effects = Effect.includes(:comments, :ratings).all
    render json: @effects.as_json(
      only: [:id, :name, :img, :description, :speed, :devices, :manual, :programs],
      methods: [:tag_list]
    )
  end

  def show
    @effect = Effect.includes(:comments, :ratings).find(params[:id])
    render json: @effect.as_json(
      only: [:id, :name, :img, :description, :speed, :devices, :manual, :programs],
      methods: [:tag_list]
    )
  end
end
