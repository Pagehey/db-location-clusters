Rails.application.routes.draw do
  root to: 'pages#with_vue'

  resources :records, only: [:index]
  resources :clusters, only: [:index]
end
