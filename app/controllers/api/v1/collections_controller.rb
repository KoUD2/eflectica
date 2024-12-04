class Api::V1::CollectionsController < ApplicationController
  def index
    @collections = Collection.includes(:ratings).all
    render json: @collections.as_json(
      only: [:id, :name, :description, :user_id],
      methods: [:tag_list]
    )
  end

  def show
    @collection = Collection.includes(:ratings).find(params[:id])
    render json: @collection.as_json(
      only: [:id, :name, :description, :user_id],
      methods: [:tag_list]
    )
  end
end
