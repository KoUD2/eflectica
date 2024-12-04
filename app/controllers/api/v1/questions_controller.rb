class Api::V1::QuestionsController < ApplicationController
  def index
    @questions = Question.includes(:comments).all
    render json: @questions.as_json(
      only: [:id, :title, :media, :description],
      methods: [:tag_list]
    )
  end

  def show
    @question = Question.includes(:comments).find(params[:id])
    render json: @question.as_json(
      only: [:id, :title, :media, :description],
      methods: [:tag_list]
    )
  end
end
