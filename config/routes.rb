Rails.application.routes.draw do
  root to: 'pages#home'

  resources :records,  only: [:index]
  resources :clusters, only: [:index]
end
