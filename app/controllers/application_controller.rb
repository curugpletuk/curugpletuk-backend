class ApplicationController < ActionController::API
require 'dotenv/load'

  attr_reader :current_user

  def encode_token(payload)
    JWT.encode(payload, ENV['SECRET_KEY'], 'HS256')
  end

  def decode_token(payload)
    JWT.decode(payload, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  attr_reader :current_user

  protected

  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
      return
    end
  
    user_id = auth_token[0]['user_id']
    @current_user = User.find_by(id: user_id)
    # @current_user = User.find(auth_token[0]['user_id'])
  
    if @current_user.nil?
      render json: { errors: ['User not found'] }, status: :not_found
      return
    end
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Forbidden'] }, status: :forbidden
  end

  private

  def http_token
    @http_token ||= request.headers['Authorization']&.split(' ')&.last
  end

  def auth_token
    @auth_token ||= JWT.decode(http_token, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def user_id_in_token?
    http_token && auth_token
  end

  def default_response(options={})
    return render json: {
      status: options[:status],
      message: options[:message],
      data: options[:data]
    }, status: options[:status]
  end

  def default_response2(options={})
    return render json: {
      status: options[:status],
      message: options[:message]
    }, status: options[:status]
  end

  def default_response3(options = {})
    return render json: {
      status: options.fetch(:status),
      message: options.fetch(:message),
      data: options.fetch(:data)
    }, status: options.fetch(:status)
  end
end
