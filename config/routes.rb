Brimir::Application.routes.draw do

  devise_for :users

  # special omniauth routes
  get 'auth/:provider/callback', to: 'omniauth#callback'
  get 'auth/failure', to: 'omniauth#failure'

  resources :users

  resources :tickets, only: [:index, :show, :update, :new, :create]

  resources :labelings, only: [:destroy, :create]

  resources :rules

  resources :labels, only: [ :destroy, :update ]

  resources :replies, only: [:create, :new]

  get '/attachments/:id/:format' => 'attachments#show'

  resources :email_addresses, only: [:index, :create, :new, :destroy]

  root to: 'tickets#index'

  namespace :api do
    namespace :v1 do
      resources :tickets, only: [ :index, :show ]
      resources :sessions, only: [ :create ]
    end
  end

end
