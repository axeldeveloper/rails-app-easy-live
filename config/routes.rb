Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html


  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  # API Routes
  namespace :api do
    namespace :v1 do
      resources :users, only: [ :create ]
      resources :keywords, only: [ :index, :show, :create, :update, :destroy ]
      # resources :comments, only: [:index, :show]
    end
  end


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
