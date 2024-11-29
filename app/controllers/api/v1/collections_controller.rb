class Api::V1::CollectionsController < ApplicationController
  def index
    @collections = Collection.includes(:ratings).all
  end

  def show
    @collection = Collection.includes(:ratings).find(params[:id])
  end
end
