Brimir::Application.routes.draw do

  resources :replies, only: [ :create, :new ]

  devise_for :users

  resources :users, only: [ :edit, :update, :index ]

  resources :tickets, only: [ :index, :show, :update, :create ]

  root :to => 'tickets#index'

end
