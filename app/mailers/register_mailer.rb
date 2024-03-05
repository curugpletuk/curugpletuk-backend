class RegisterMailer < ApplicationMailer
  require 'figaro'
  Figaro.application = Figaro::Application.new(environment: "production", path: "/config/application.yml")
  Figaro.load
  
  # default from: 'somarjakit@gmail.com'
  
  def send_register_email(user, token_activation)
      @user = user
      @token_activation = token_activation
      @url_server = ENV['URL_HOST']
      mail(to: @user.email, subject: 'Verification Account Instruction')
  end
end
