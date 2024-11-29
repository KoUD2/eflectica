class Api::V1::QuestionsController < ApplicationController
  def index
    @questions = Question.includes(:comments).all
  end

  def show
    @question = Question.includes(:comments).find(params[:id])
  end
end
