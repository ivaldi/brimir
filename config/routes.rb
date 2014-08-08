Brimir::Application.routes.draw do

  devise_for :users

  resources :users

  resources :tickets, only: [:index, :show, :update, :new, :create]

  resources :labelings, only: [:destroy, :create]

  resources :replies, only: [:create, :new]
  get '/attachments/:id/:format' => 'attachments#show'

  root :to => 'tickets#index'

end
