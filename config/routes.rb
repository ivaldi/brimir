Brimir::Application.routes.draw do

  devise_for :users

  resources :users, only: [ :edit, :update, :index ]

  resources :tickets, only: [ :index, :show, :update, :create ]
  resources :replies, only: [ :create, :new ]
  get '/attachments/:id/:format' => 'attachments#show'

  root :to => 'tickets#index'

end
