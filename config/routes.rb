Rails.application.routes.draw do

  # resources :feedbacks
  root 'static_pages#home'
  get '/login', to: 'sessions#new'
  post '/login', to:'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post '/auth', to: 'tickets#authenticate'

  get 'tickets/authenticate'

  get 'home' => 'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'contact' => 'static_pages#contact'
  get '/feedbacks/new' => 'feedbacks#new'
  get '/feedbacks' => 'feedbacks#index'

  put '/reset_sp_key/:id' => 'service_providers#reset_keys'

  put '/password_resets' => 'password_resets#update', as: :password_resets
  get '/password_resets/edit' => 'password_resets#edit', as: :edit_password_resets
  resources :users
  resources :service_providers
  resources :password_resets, only: [:new, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
