class Api::V1::EffectsController < ApplicationController
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
end
