Rails.application.routes.draw do
 root to: 'pages#index'
 
 get '/home', to: 'pages#temp'
 
 get '/register', to: 'users#new'
 
 get '/sign_in', to: 'sessions#new'
 post '/sign_in', to: 'sessions#create'
 get '/sign_out', to: 'sessions#destroy'
 
 get 'ui(/:action)', controller: 'ui'
 
 resources :users
end
