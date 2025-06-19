Rails.application.routes.draw do
  get "profiles/show"
  resources :links
  resources :images, only: [:show, :update, :destroy]
  resources :news_feeds
  devise_for :users

  namespace :api, format: 'json' do
    namespace :v1 do
      resources :sub_collections, only: [:index, :show, :create, :destroy]

      resources :likes, only: [:create, :index, :show] do
        collection do
          delete '', to: 'likes#destroy'
        end
      end

      resources :effects, only: [:index, :show, :destroy] do
        collection do
          get 'my', to: 'effects#my_effects'
          get 'feed', to: 'effects#feed'
        end
        resources :comments, only: [:index, :show, :create, :update, :destroy]
      end
      resources :users, only: [:index, :show] do
        collection do
          get 'me', to: 'users#me'
        end
      end
      
      resources :profiles, only: [:show] do
        collection do
          get 'me', to: 'profiles#me'
          patch '', to: 'profiles#update'
          delete '', to: 'profiles#destroy'
        end
      end
      
      resources :favorites, only: [:create] do
        delete ":effect_id", to: "favorites#destroy", on: :collection
      end      
      resources :collections, only: [:index, :show, :create, :destroy] do
        collection do
          get 'my', to: 'collections#my_collections'
        end
        member do
          patch 'update_status'
          post 'effects/:effect_id', to: 'collections#add_effect', as: 'add_effect'
          delete 'effects/:effect_id', to: 'collections#remove_effect', as: 'remove_effect'
          post 'effects/bulk_add', to: 'collections#bulk_add_effects', as: 'bulk_add_effects'
          post 'links', to: 'collections#add_link', as: 'add_link'
          patch 'links/:link_id', to: 'collections#update_link', as: 'update_link'
          delete 'links/:link_id', to: 'collections#remove_link', as: 'remove_link'
          post 'images', to: 'collections#add_image', as: 'add_image'
          patch 'images/:image_id', to: 'collections#update_image', as: 'update_image'
          delete 'images/:image_id', to: 'collections#remove_image', as: 'remove_image'
        end
        resources :collection_effects, only: [:create], path: 'effects'
      end

      devise_scope :user do
        post "sign_up", to: "registrations#create"
        post "sign_in", to: "sessions#create"
        post "sign_out", to: "sessions#destroy"
      end
    end
  end

  resources :profiles, only: [:show, :edit, :update]

  # get 'profiles/:id', to: 'profiles#show', as: 'profile'

  # Custom route for deleting effects from collections
  delete 'remove_effect_from_collection/:collection_id/:effect_id', to: 'collection_effects#destroy_by_ids', as: :remove_effect_from_collection

  resources :sub_collections
  resources :collection_effects
  resources :collections, path: 'collection' do
    resources :links, only: [:index]
    resources :images
    collection do
      get 'tagged/:tag', to: 'collections#by_tag', as: :tagged
      get 'search', to: 'collections#search'
    end
    member do
      post 'subscribe'
      delete 'unsubscribe'
      post 'effects/bulk_add', to: 'collections#bulk_add_effects'
      post 'effects/bulk_update', to: 'collections#bulk_update_effects'
      post 'add_link', to: 'collections#add_link'
    end
  end

  get 'effects/categorie/:category', to: 'effects#categorie', as: :effects_categorie

  # Trending routes
  get 'effects/trending', to: 'effects#trending', as: :trending_effects
  get 'collections/trending', to: 'collections#trending', as: :trending_collections
  get 'collections/similar', to: 'collections#similar', as: :similar_collections
  get 'effects/similar', to: 'effects#similar', as: :similar_effects

  resources :subscriptions, only: [:create]
  resources :favorites do
    collection do
      post 'add_link', to: 'favorites#add_link'
      post 'add_image', to: 'favorites#add_image'
      delete 'links/:link_id', to: 'favorites#remove_link', as: 'remove_link'
      patch 'links/:link_id', to: 'favorites#update_link', as: 'update_link'
      delete 'images/:image_id', to: 'favorites#remove_image', as: 'remove_image'
      patch 'images/:image_id', to: 'favorites#update_image', as: 'update_image'
      get 'links/:link_id', to: 'favorites#show_link', as: 'show_link'
      get 'images/:image_id', to: 'favorites#show_image', as: 'show_image'
    end
  end
  
  # Bulk add effects to collection route
  post 'collections/:id/effects/bulk_add', to: 'collections#bulk_add_effects', as: :bulk_add_effects_to_collection
  
  resources :effects do
    collection do
      get 'my', to: 'effects#my', as: :my
      post 'save_preferences', to: 'effects#save_preferences'
    end
    member do
      patch :approve
      patch :reject
    end
    collection do
      get 'categories', to: 'effects#categories'
      get 'tagged/:tag', to: 'effects#by_tag', as: :tagged
    end
    resources :comments do
      resources :ratings, only: [:create]
    end
  end

  # OG Images routes
  get 'og_images/effect/:id', to: 'og_images#effect', as: :og_image_effect
  get 'og_images/collection/:id', to: 'og_images#collection', as: :og_image_collection
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get 'about', to: 'welcome#about', as: 'welcome_about'
  get 'search', to: 'welcome#search', as: 'search_results'
  # get 'about', to: 'welcome#about'
  # get 'allTasks', to: 'welcome#allTasks'
  # get 'searchTasks', to: 'welcome#searchTasks'
  # get 'howToPlay', to: 'welcome#howToPlay'
  # get 'answersGallery', to: 'tasks#answersGallery'

  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all

  # Defines the root path route ("/")
  root "welcome#index"
  
  # Catch all unmatched routes (must be last)
  match '*path', to: 'errors#not_found', via: :all
end
