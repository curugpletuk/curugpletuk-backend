Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  #Users Routes
  get '/verification-account', to: 'users#email_verification'
  post '/auth/signup', to: 'users#create'
  post '/auth/resend', to: 'users#resend_verification'
  get '/me', to: 'users#show_current_user'
  put '/users/update_profile', to: 'users#update_profile'
  put '/users/update_password', to: 'users#update_password'
  put '/users/remove_avatar', to: 'users#remove_avatar'
  post '/users/email_verification', to: 'users#email_verification'
  delete '/users/destroy', to: 'users#destroy'
  
  #Session
  post '/auth/login', to: 'sessions#create'
  delete '/auth/logout', to: 'sessions#destroy'

  #Forgot Password Routes
  post '/forgot_password', to: 'password_resets#create', as: 'forgot_password'
  get '/check_reset_token', to: 'password_resets#check_reset_token', as: 'check_reset_token'
  patch '/update_password/:id', to: 'password_resets#update', as: 'update_password'

  #Order
  post "/orders", to: "orders#create"
  get "/orders", to: "orders#index"
  get "/orders/:id", to: "orders#show"
  # Get All Order for User
  get '/check_user_order', to: 'orders#check_user_order'
  # Get Order Chart
  get 'orders/chart', to: 'orders#order_chart', as: 'order_chart'
  # Get Download
  get 'orders/download/:year/:month', to: 'orders#download', as: 'download_orders'
  # Checked by Admin
  post '/orders/:id/check_order', to: 'orders#checked_order'

  #Product
  get "/products", to: "products#index"
  get "/products/:id", to: "products#show"
  post "/products", to: "products#create"
  put "/products/update/:id", to: "products#update"
  delete "/products/destroy/:id", to: "products#destroy"


  resources :users
  resources :products
  resources :roles
  resources :images
  resources :sessions
  resources :notifications
  
  
end
