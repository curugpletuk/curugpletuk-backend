class UsersController < ApplicationController
  before_action :authenticate_request!, except: %i[create email_verification show resend_verification]
  before_action :user_valid?, only: [:create]
  
  def index
    @users = User.all
    render json: { status: 200, data: @users.map {|user| user.new_attributes} }, status: 200
  end

  def show
    render json: { status: 200, data: @user }, status: 200
  end

  def show_current_user
    render json: { status: 200, message: 'Data Pengguna', data: current_user.profile_attributes }, status: 200
  end

  def create
    user = User.create_with_params(params)
    default_response(user)
  end

  def resend_verification
    user = User.resend_token_register(params)
    default_response(user)
  end

  def update_profile
    current_user.skip_password_validation = true
    user = current_user.update_profile(profile_params, avatar_params)
    default_response(user)
  end

  def remove_avatar
    user = current_user.remove_avatar
    default_response(user)
  end

  def update_password
    user = current_user.update_password(user_params)
    default_response(user)
  end
  
  def email_verification
    user = User.verify_account(params)
    default_response2(user)
  end

  def destroy
    user = current_user.destroy_with_sessions(current_user)
    default_response2(user)
  end

  private
  def user_params
    params.permit(:name, :email, :password, :current_password, :bio)
  end
  
  def avatar_params
    params.permit(:image)
  end

  def profile_params
    params.permit(:name, :bio)
  end

  def user_valid?
    user = User.validate_user(user_params['email'])
    if user == true
      true
    else
      default_response2(user)
    end
  end

end
