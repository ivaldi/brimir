Brimir::Application.routes.draw do

  resources :replies, only: [ :create ]

  devise_for :users

  resources :users, only: [ :edit, :update ]

  resources :tickets, only: [ :index, :show, :update, :create ]

  root :to => 'tickets#index'

end
