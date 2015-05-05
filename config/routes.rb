require 'sidekiq/web'

Rails.application.routes.draw do
 
  get '/home', to: 'requests#index'
  get '/my_request', to: 'requests#new'
  post '/my_request', to: 'requests#create'
  get '/edit_my_request/:id', to: 'requests#edit', as: :edit_my_request
  put '/edit_my_request/:id', to: 'requests#update', as: :update_my_request
  get '/my_babysitting_dates', to: 'requests#my_babysitting_dates'
  put '/cancel_babysitting_date/:id', to: 'requests#cancel_babysitting_date', as: :cancel_babysitting_date
  resources :requests, only: [:destroy]

  get '/register', to: 'users#new'
  post '/register', to: 'users#create'
  get '/register/:identifier', to: 'users#new_invitation_with_identifier', as: :register_with_identifier
  resources :users, only: [:show] do
    get :search, on: :collection
  end

  get '/sign_in', to: 'sessions#new'
  post '/sign_in', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'
  
  get '/auth/:provider/callback', to: 'authentications#create' #omniauth route

  get '/new_group', to: 'groups#new'
  resources :groups, only: [:create, :show] do
    member do
      get '/invite_friend', to: 'group_invitations#new'
      post '/invite_friend', to: 'group_invitations#create'
    end
  end

  resources :request_groups, only: [:show, :update]
  
  get '/forgot_password', to: 'forgot_passwords#new'
  post '/forgot_password', to: 'forgot_passwords#create'
  get '/forgot_password_confirmation', to: 'forgot_passwords#confirm'
  
  resources :password_resets, only: [:show, :create]
  
  resources :join_group_requests, only: [:create]
  get '/join_group/:identifier', to: 'join_group_requests#show', as: :join_user_group_with_identifier
  
  get '/expired_password_token', to: 'pages#expired_password_token'
  get '/expired_identifier', to: 'pages#expired_identifier'
  root to: 'pages#index'
  
  get 'ui(/:action)', controller: 'ui'
  
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web => '/sidekiq'
 
end
