class PasswordResetsController < ApplicationController
  before_action :set_email, only: [:create]
    
  def create
    user = User.generate_and_send_password_reset_email(params[:email])
    default_response(user)
  end
  
  def update
    user = User.reset_password(params[:id], password_reset_params)
    default_response(user)
  end

  def check_reset_token 
    user = User.check_reset_token(params[:reset_password_token])
    default_response(user)
  end
    
  private
  def password_reset_params
    params.permit(:password, :password_confirmation, :reset_password_token)
  end

  def set_email
    user = User.password_reset_params(params)
    if user == true
      true
    else
      default_response2(user)
    end
  end

end
