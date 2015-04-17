Rails.application.routes.draw do
 
 get '/home', to: 'requests#index'
 get '/my_request', to: 'requests#new'
 post '/my_request', to: 'requests#create'
 get '/my_babysitting_dates', to: 'requests#my_babysitting_dates'
 put '/cancel_babysitting_date/:id', to: 'requests#cancel_babysitting_date', as: :cancel_babysitting_date
 
 get '/register', to: 'users#new'
 post '/register', to: 'users#create'
 
 get '/sign_in', to: 'sessions#new'
 post '/sign_in', to: 'sessions#create'
 get '/sign_out', to: 'sessions#destroy'
 
 get '/new_group', to: 'groups#new'
 
 resources :groups, only: [:create, :show]
 
 resources :request_groups, only: [:show, :update]
 
 root to: 'pages#index'
 get 'ui(/:action)', controller: 'ui'
 
end
