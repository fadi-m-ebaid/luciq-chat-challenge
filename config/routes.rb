require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'

  # API routes
  namespace :api do
    namespace :v1 do
      resources :applications, param: :token, only: [:create, :show, :update] do
        resources :chats, param: :number, only: [:create, :index, :show] do
          resources :messages, param: :number, only: [:create, :index, :show] do
            collection do
              get :search
            end
          end
        end
      end
    end
  end
end
