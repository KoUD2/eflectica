class CollectionsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_collection, only: %i[ show edit update destroy ]

  # GET /collections or /collections.json
  def index
    @subscribed_collections = current_user.subscribed_collections if user_signed_in?
    @collections = Collection.where.not(user_id: current_user.id)
                             .where(status: 'public')
                             .order(created_at: :desc)
  end

  def by_tag
    @collections = Collection.tagged_with(params[:tag])
    render :index
  end

  # GET /collections/1 or /collections/1.json
  def show
    @collection = Collection.find(params[:id])
    @programs = helpers.programs
  end

  # GET /collections/new
  def new
    render layout: 'application'
    @collection = Collection.new
  end

  def subscribe
    @collection = Collection.find(params[:id])
    
    if @collection.status != 'private' && !current_user.subscribed_to?(@collection)
      subscription = SubCollection.new(user: current_user, collection: @collection)
      
      if subscription.save
        respond_to do |format|
          format.html { 
            flash[:notice] = 'Вы успешно подписались на коллекцию'
            if turbo_frame_request?
              render partial: 'collections/subscription_button', locals: { collection: @collection }
            else
              redirect_to @collection
            end
          }
          format.turbo_stream { 
            render turbo_stream: turbo_stream.replace('subscription_button', 
            partial: 'collections/subscription_button', 
            locals: { collection: @collection })
          }
          format.json { 
            html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection }, formats: [:html])
            render json: { status: 'success', message: 'Вы успешно подписались на коллекцию', html: html } 
          }
        end
      else
        respond_to do |format|
          format.html { 
            flash[:alert] = 'Не удалось подписаться на коллекцию'
            if turbo_frame_request?
              render partial: 'collections/subscription_button', locals: { collection: @collection }
            else
              redirect_to @collection
            end
          }
          format.turbo_stream { 
            render turbo_stream: turbo_stream.replace('subscription_button', 
            partial: 'collections/subscription_button', 
            locals: { collection: @collection })
          }
          format.json { 
            html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection }, formats: [:html])
            render json: { status: 'error', message: 'Не удалось подписаться на коллекцию', html: html }, status: :unprocessable_entity
          }
        end
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = 'Вы не можете подписаться на эту коллекцию'
          if turbo_frame_request?
            render partial: 'collections/subscription_button', locals: { collection: @collection }
          else
            redirect_to @collection
          end
        }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace('subscription_button', 
          partial: 'collections/subscription_button', 
          locals: { collection: @collection })
        }
        format.json { 
          html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection }, formats: [:html])
          render json: { status: 'error', message: 'Вы не можете подписаться на эту коллекцию', html: html }, status: :unprocessable_entity
        }
      end
    end
  end  

  def unsubscribe
    @collection = Collection.find(params[:id])
    subscription = current_user.sub_collections.find_by(collection: @collection)
    
    if subscription&.destroy
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Вы успешно отписались от коллекции'
          if turbo_frame_request?
            render partial: 'collections/subscription_button', locals: { collection: @collection }
          else
            redirect_to @collection
          end
        }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace('subscription_button', 
          partial: 'collections/subscription_button', 
          locals: { collection: @collection })
        }
        format.json { 
          html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection }, formats: [:html])
          render json: { status: 'unsubscribed', html: html } 
        }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = 'Не удалось отписаться от коллекции'
          if turbo_frame_request?
            render partial: 'collections/subscription_button', locals: { collection: @collection }
          else
            redirect_to @collection
          end
        }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace('subscription_button', 
          partial: 'collections/subscription_button', 
          locals: { collection: @collection })
        }
        format.json { 
          html = render_to_string(partial: 'collections/subscription_button', locals: { collection: @collection }, formats: [:html])
          render json: { error: 'Не удалось отписаться', html: html }, status: :unprocessable_entity
        }
      end
    end
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections or /collections.json
  def create
    @collection = current_user.collections.new(collection_params)

    if @collection.save
      flash[:notice] = "Коллекция успешно создана!"
      redirect_to news_feeds_path
    else
      flash[:alert] = "Не удалось создать коллекцию. Проверьте введённые данные."
      redirect_back(fallback_location: collections_path)
    end
  end

  # PATCH/PUT /collections/1 or /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: "Коллекция была обновлена" }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1 or /collections/1.json
  def destroy
    @collection.destroy!

    respond_to do |format|
      format.html { redirect_to collections_path, status: :see_other, notice: "Коллекция была удалена" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:name, :description, :status, :user_id)
    end
end
