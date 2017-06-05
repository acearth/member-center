Rails.application.routes.draw do
  get 'reset_password' => 'reset_password#new'
  put 'reset_password' => 'reset_password#create'

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

  resources :users
  resources :service_providers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
