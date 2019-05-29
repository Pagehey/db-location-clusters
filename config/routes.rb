Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#with_vue'
  get 'vanilla_js', to: 'pages#vanilla_js'

  resources :records, only: [:index]
  get 'clusters', to: 'records#clusters'
end
