Rails.application.routes.draw do
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

      resources :effects, only: [:index, :show] do
        resources :comments, only: [:index, :show, :create, :update, :destroy]
      end
      resources :questions, only: [:index, :show, :create, :update] do
        resources :comments, only: [:index, :show, :create, :update, :destroy]
      end
      resources :users, only: [:index, :show]
      resources :favorites, only: [:create] do
        delete ":effect_id", to: "favorites#destroy", on: :collection
      end      
      resources :collections, only: [:index, :show, :create] do
        member do
          patch 'update_status'
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

  resources :sub_collections
  resources :collection_effects
  resources :collections do
    collection do
      get 'tagged/:tag', to: 'collections#by_tag', as: :tagged
    end
  end
  resources :questions do
    collection do
      get 'tagged/:tag', to: 'questions#by_tag', as: :tagged
    end
    resources :comments, only: [:create, :destroy]
    resources :ratings, only: [:create]
  end
  resources :subscriptions, only: [:create]
  resources :favorites
  resources :effects do
    collection do
      get 'tagged/:tag', to: 'effects#by_tag', as: :tagged
    end
    resources :comments, only: [:create, :destroy] 
    resources :ratings, only: [:create]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get 'about', to: 'welcome#about', as: 'welcome_about'
  # get 'about', to: 'welcome#about'
  # get 'allTasks', to: 'welcome#allTasks'
  # get 'searchTasks', to: 'welcome#searchTasks'
  # get 'howToPlay', to: 'welcome#howToPlay'
  # get 'answersGallery', to: 'tasks#answersGallery'

  # Defines the root path route ("/")
  root "effects#index"
end
