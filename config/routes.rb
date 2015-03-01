Rails.application.routes.draw do
 root to: 'pages#home'
 get 'ui(/:action)', controller: 'ui'
end
