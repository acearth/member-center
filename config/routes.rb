Rails.application.routes.draw do
  # resources :feedbacks
  root 'sessions#new'
  get '/login', to: 'sessions#new'
  post '/login', to:'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post '/auth', to: 'tickets#authenticate'

  get 'tickets/authenticate'

  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get '/feedbacks/new' => 'feedbacks#new'
  get '/feedbacks' => 'feedbacks#index'

  put '/reset_sp_key/:id' => 'service_providers#reset_keys'

  resources :users
  resources :service_providers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
