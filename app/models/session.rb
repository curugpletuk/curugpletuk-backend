class Session < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :device, presence: true
  validates :ip_address, presence: true

  def self.create_session(user_params, request)
    user = User.find_by(email: user_params[:email])

    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email dan Password harus diisi' } if user_params[:email].blank? && user_params[:password].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email harus diisi' } if user_params[:email].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Password harus diisi' } if user_params[:password].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email harus sesuai format' } unless user_params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Akun belum terdaftar' } if user.nil?
    
    if user.email_confirmed && user.authenticate_password(user_params[:password])
      save_session(user, request)
    elsif !user.email_confirmed
      return { code: 403, status: "FORBIDDEN", message: 'Verifikasi akun terlebih dahulu untuk login' }
    else
      return { code: 401, status: "UNAUTHORIZED", message: 'Email atau Kata sandi anda salah' }
    end
  end

  def self.destroy_session(access_token)
    if access_token.present?
      access_token = access_token.split(" ")[1].tr('\"', '')
      session_data = Session.find_by(token: access_token)
    end

    if session_data.nil?
      return { code: 401, status: "UNAUTHORIZED", message: 'Token anda tidak valid' }
    else
      session_data.destroy
      return { code: 200, status: "OK", message: 'Anda telah berhasil keluar dari sesi' }
    end
  end
  
  private

  def self.generate_login_token(user_id)
    payload = { user_id: user_id }
    expired_time = 3600 * 600
    exp = Time.now.to_i + expired_time
    payload[:exp] = exp
    JWT.encode(payload, ENV['SECRET_KEY'], 'HS256')
  end

  # def self.generate_login_token(user_id)
  #   payload = { user_id: user_id }
  #   JWT.encode(payload, ENV['SECRET_KEY'], 'HS256')
  # end

  def self.save_session(user, request)
    user_sessions = Session.where(user_id: user.id)
    device_id = device_id(request)

    if user_sessions.exists?(device_id: device_id)
      return { code: 201, status: "CREATED", message: 'Anda telah berhasil login', data: { user: user.new_attributes, token: user_sessions.find_by(device_id: device_id).token } }
    else
      device = DeviceDetector.new(request.headers['User-Agent'])
      session = Session.create({
        token: generate_login_token(user.id),
        ip_address: request.remote_ip,
        device: device.os_name || device.name,
        device_id: device_id,
        user_id: user.id,
        last_active: Time.now
      })
      return { code: 201, status: "CREATED", message: 'Anda telah berhasil login', data: { user: user.new_attributes, token: session.token } }
    end
  end

  # def self.save_session(user, request)
  #   user_session = Session.find_by(user_id: user.id)
  #   if user_session.present?
  #     return { code: 403, status: "FORBIDDEN", message: 'Anda telah login dengan akun ini sebelumnya, mohon logout terlebih dahulu' }
  #   else
  #     device = DeviceDetector.new(request.headers['User-Agent'])
  #     session = Session.create({
  #       token: generate_login_token(user.id),
  #       ip_address: request.remote_ip,
  #       device: device.os_name || device.name,
  #       device_id: device_id(request),
  #       user_id: user.id,
  #       last_active: Time.now
  #     })
  #     return { code: 201, status: "CREATED", message: 'Anda telah berhasil login', data: { user: session.user.new_attributes, token: session.token } }
  #   end
  # end

  def self.device_id(request)
    "#{request.remote_ip}-#{request.headers['User-Agent']}"
  end

end
