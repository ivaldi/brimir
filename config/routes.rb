Brimir::Application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth' }

  resources :users do
    get :tickets, to: 'tickets#index'
  end

  namespace :tickets do
    resource :deleted, only: :destroy, controller: :deleted
    resource :selected, only: :update, controller: :selected
  end

  resources :tickets, except: [:destroy, :edit] do
    resource :lock, only: [:destroy, :create], module: :tickets
  end

  get "/:hook/:mail_key/tickets",
    controller: 'tickets',
    action: 'create',
    constraints: ->(r) { r.path_parameters[:hook].in? TicketsController::MAIL_HOOKS },
    format: :json

  resources :labelings, only: [:destroy, :create]

  resources :rules

  resources :email_templates

  resources :labels, only: [:destroy, :update, :index, :edit]

  resources :replies, only: [:create, :new, :update, :show] do
    resource  :split_off, controller: 'tickets/split_off', only: [:create]
  end

  get '/attachments/:id/:format' => 'attachments#show'
  resources :attachments, only: [:index, :new]

  resources :email_addresses
  resources :email_imports, only: [:new, :create]

  resource :settings, only: [:edit, :update]

  root to: 'tickets#index'

  namespace :api do
    namespace :v1 do
      resources :email_templates, only: [ :show ]
      resources :tickets, only: [ :index, :show, :create ]
      resources :sessions, only: [ :create ]
      resources :users, param: :email, only: [ :create, :show ] do
        resources :tickets, only: [ :index ]
      end
    end
  end

end
