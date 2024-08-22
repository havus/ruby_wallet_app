Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  # get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  # get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :auth do
        resources :sign_up, only: :create
        resources :sign_in, only: :create
      end
      resources :users, only: [:index, :show, :create] do
        member do
          get :wallet
        end
      end
      resources :teams, only: [:index, :show, :create] do
        member do
          get :wallet
        end
      end
      resources :stocks, only: [:index, :show, :create] do
        member do
          get :wallet
        end
      end

      namespace :wallet_transactions do
        resources :deposit, only: :create
        resources :withdraw, only: :create
        resources :transfer, only: :create
      end
      resources :wallets, only: [:create, :show]
    end
  end
end
