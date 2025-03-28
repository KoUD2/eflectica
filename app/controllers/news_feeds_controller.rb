class NewsFeedsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_news_feed, only: %i[ show edit update destroy ]

  # GET /news_feeds or /news_feeds.json
  def index
    @news_feeds = current_user.news_feeds.includes(:effect).page(params[:page]).per(10)
    @my_collections = current_user.collections
    @collections = Collection.all
    @favorite_effects = current_user.favorites.includes(effect: :images).map(&:effect)
    @my_collections = current_user.collections.includes(effects: :images)
    @subscribed_collections = current_user.sub_collections
                                            .joins(:collection)
                                            .where.not(collections: { user_id: current_user.id })
                                            .map(&:collection)
  end

  # GET /news_feeds/1 or /news_feeds/1.json
  def show
  end

  # GET /news_feeds/new
  def new
    @news_feed = current_user.news_feeds.new
  end

  # GET /news_feeds/1/edit
  def edit
  end

  # POST /news_feeds or /news_feeds.json
  def create
    @news_feed = NewsFeed.new(news_feed_params)

    respond_to do |format|
      if @news_feed.save
        format.html { redirect_to @news_feed, notice: "News feed was successfully created." }
        format.json { render :show, status: :created, location: @news_feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @news_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news_feeds/1 or /news_feeds/1.json
  def update
    respond_to do |format|
      if @news_feed.update(news_feed_params)
        format.html { redirect_to @news_feed, notice: "News feed was successfully updated." }
        format.json { render :show, status: :ok, location: @news_feed }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @news_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_feeds/1 or /news_feeds/1.json
  def destroy
    @news_feed.destroy!

    respond_to do |format|
      format.html { redirect_to news_feeds_path, status: :see_other, notice: "News feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news_feed
      @news_feed = NewsFeed.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def news_feed_params
      params.require(:news_feed).permit(:user_id, :effect_id, :collection_id)
    end
end
