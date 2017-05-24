Rails.application.routes.draw do
  get 'sessions/new'

  get 'sessions/create'

  get 'sessions/destroy'

  get 'tickets/auth'

  resources :service_providers
  get 'static_pages/home'

  get 'static_pages/help'

  get 'static_pages/contact'

  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
