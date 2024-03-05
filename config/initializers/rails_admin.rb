RailsAdmin.config do |config|
  config.asset_source = :sprockets

  config.model User do
    create do 
      field :name
      field :email 
      field :password
      field :role
    end
    edit do 
      field :email 
      field :password
      field :role
      field :email_confirmed
      field :phone_number
      field :bio
    end
    # list do 
    #   field :id, :email, :password_digest, :phone_number, :bio, :created_at, :updated_at, 
    #   :reset_password_token, :reset_password_sent_at, :role, :confirm_token,
    #   :confirm_token_sent_at, :email_confirmed
    # end
  end

  # config.model Role do 
  #   field :id, :name, :created_at, :updated_at
  # end

  # config.authenticate_with do
  #   authenticate_or_request_with_http_basic('Login is required') do |email, password|
  #     @user = User.find_by_email(email)
  #     @user.authenticate(password) && @user.role_id == 1 if @user
  #   end
  # end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true


    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
