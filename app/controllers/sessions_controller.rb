class SessionsController < ApplicationController
  def create
    user = Session.create_session(user_params, request)
    default_response(user)
  end

  def destroy
    access_token = request.headers['Authorization']
    result = Session.destroy_session(access_token)
    # render json: { code: result[:code], status: result[:status], message: result[:message] }, status: result[:status]
    default_response(result)
  end

  private
  def user_params
    params.permit(:email, :password)
  end
end
