Rails.application.routes.draw do
  default_url_options host: 'genius.internal.worksap.com'

  namespace :admin do
    get 'users/index'
    post 'users/role'
  end

  # resources :feedbacks
  root 'static_pages#home'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post '/auth', to: 'tickets#authenticate'

  get 'tickets/authenticate'

  get 'home' => 'static_pages#home'
  get 'help' => 'static_pages#help'
  get 'contact' => 'static_pages#contact'
  get '/feedbacks/new' => 'feedbacks#new'
  get '/feedbacks' => 'feedbacks#index'

  put '/reset_sp_key/:id' => 'service_providers#reset_keys'

  put '/password_resets' => 'password_resets#update', as: :password_resets
  get '/password_resets/edit' => 'password_resets#edit', as: :edit_password_resets
  get '/users/:id/activate' => 'users#activate', as: :activate_user
  match '/users/:id/update_password' => 'users#update_password', as: :update_password, via: [:patch, :put]
  get '/users/:id/reset_otp_key' => 'users#reset_otp_key', as: :reset_otp_key
  put '/users/:id/demand_otp_key' => 'users#demand_otp_key', as: :request_new_otp_key
  resources :users
  resources :service_providers
  resources :password_resets, only: [:new, :create]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post 'login', to: 'genius#login'
      post 'auth', to: 'genius#authenticate'
      get 'genius_exist', to: 'genius#exist?'
      get 'bonjour', to: 'genius#bonjour'
      get 'jwt_user', to: 'genius#jwt_user'
    end
  end
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
