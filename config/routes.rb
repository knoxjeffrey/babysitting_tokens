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

  get '/sign_in', to: 'sessions#new'
  post '/sign_in', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy'

  get '/new_group', to: 'groups#new'
  resources :groups, only: [:create, :show]

  resources :request_groups, only: [:show, :update]
  
  get '/forgot_password', to: 'forgot_passwords#new'
  post '/forgot_password', to: 'forgot_passwords#create'
  get '/forgot_password_confirmation', to: 'forgot_passwords#confirm'
  
  resources :password_resets, only: [:show, :create]
  
  get '/expired_token', to: 'pages#expired_token'
  root to: 'pages#index'
  
  get 'ui(/:action)', controller: 'ui'
 
end
