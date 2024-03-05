class ForgotPasswordMailer < ApplicationMailer
  require 'figaro'
  Figaro.application = Figaro::Application.new(environment: "production", path: "/config/application.yml")
  Figaro.load
  
  # default from: 'somarjakit@gmail.com'
  
  def password_reset(user)
      @user = user
      mail to: @user.email, subject: "Reset Password Instruction"
  end
end
