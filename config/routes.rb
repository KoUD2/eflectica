Rails.application.routes.draw do
  devise_for :users

  namespace :api, format: 'json' do
    namespace :v1 do
      resources :effects, only: [:index, :show]
      resources :questions, only: [:index, :show]
      resources :users, only: [:index, :show]
      resources :collections, only: [:index, :show]
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
  root "welcome#index"
end
