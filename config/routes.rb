Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

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
  resources :orders, only: [:create, :index, :show]
  post "/orders/notification_handler", to: "orders#notification_handler"
  get "/orders/:id/cancel", to: "orders#cancel"
  # post "/orders/presence_user", to: "orders#presence_user"

  resources :products
  resources :roles
  # resources :orders
  
end
