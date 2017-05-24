Rails.application.routes.draw do
  root 'sessions#new'
  get '/login', to: 'sessions#new'
  post '/login', to:'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post '/auth', to: 'tickets#authenticate'

  get 'tickets/authenticate'

  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'

  resources :users
  resources :service_providers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
