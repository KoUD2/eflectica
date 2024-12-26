class QuestionsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_question, only: %i[ show edit update destroy ]

  # GET /questions or /questions.json
  def index
    @top_questions = Question.first(4)

    if params[:search].present?
      @questions = Question.search(params[:search]).page(params[:page]).per(10)
    else
      @questions = Question.all.page(params[:page]).per(10)
    end
  end

  def by_tag
    @questions = Question.tagged_with(params[:tag])
    render :index
  end

  # GET /questions/1 or /questions/1.json
  def show
    @question = Question.find(params[:id])
    @comments = @question.comments
    @rating = Rating.new
  end

  # GET /questions/new
  def new
    render layout: 'application'
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions or /questions.json
  def create
    @question = current_user.questions.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: "Вопрос был успешно создан" }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1 or /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: "Вопрос был обновлен" }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1 or /questions/1.json
  def destroy
    @question.destroy!

    respond_to do |format|
      format.html { redirect_to questions_path, status: :see_other, notice: "Вопрос был удален" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def question_params
      params.require(:question).permit(:title, :media, :description, :user_id, tag_list: [])
    end
end
