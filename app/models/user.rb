class User < ApplicationRecord
  attr_accessor :password_reset_token
  attr_accessor :skip_password_validation

  after_create :create_avatar
  # mount_uploader :image, ImageUploader

  # VALID_PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[\W_]).{8,}\z/
  VALID_PASSWORD_REGEX = /\A(?=.*[a-zA-Z])(?=.*[\d\W_]).{8,20}\z/
  has_secure_password validations: false
  
  belongs_to :role
  has_one :avatar, as: :imageable, class_name: 'Image', dependent: :destroy
  has_many :notifications, dependent: :delete_all
  has_many :orders
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :name, presence: { message: "Nama harus diisi"}
  validates :name, length: { maximum: 50,  message: "Nama tidak boleh lebih dari 50 karakter"}
  validates :name, format: { with: /\A(?!.*[0-9])(?!.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?])/, message: "Nama tidak boleh mengandung angka dan karakter khusus" }
  validates :email, presence: { message: "Email harus diisi"}, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: true
  validates :email, presence: { message: "Email harus diisi"}, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :email, length: { maximum: 50, message: "Email tidak boleh lebih dari 50 karakter" }
  validates :password, presence: { message: "Password harus di isi"}, if: -> { !skip_password_validation }
  validates :password, length: {minimum: 8, message: "Password tidak boleh kurang dari 8 karakter"}, if: -> { !skip_password_validation }
  validates :password, length: {maximum: 20, message: "Password tidak boleh lebih dari 20 karakter"}, if: -> { !skip_password_validation }
  validates :password, format: {with: VALID_PASSWORD_REGEX, message: "Password harus berisi kombinasi huruf besar atau kecil dan angka/karakter khusus (!$@%)"}, if: -> { !skip_password_validation }
  validates :reset_password_token, presence: true, unless: :resetting_password?
  validates :address, length: { maximum: 50, message: "Alamat tidak boleh lebih dari 50 karakter" }
  validates :phone_number, numericality: { only_integer: true, message: "Nomor Handphone hanya boleh berisi angka"}, allow_nil: true
  validates :phone_number, format: { with: /\A08/, message: "Nomor Handphone harus diawali dengan '08'" }, allow_nil: true
  validates :phone_number, length: {minimum: 12, message: "Nomor Handphone tidak boleh kurang dari 12 digit"}, allow_nil: true
  validates :phone_number, length: {maximum: 16, message: "Nomor Handphone tidak boleh lebih dari 16 digit"}, allow_nil: true
  


  def resetting_password?
    reset_password_token.nil?
  end

  def generate_password_reset_token
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_token_sent_at = Time.zone.now
    save(validate: false)
  end

  def reset_password_token_used
    self.reset_password_token = nil
    self.reset_password_token_sent_at = nil
    save
  end

  def email_token(token)
    token = token['email_verification']
    if token.nil?
      false
    else
      email_token_decode(token)
    end
  rescue JWT::VerificationError, JWT::DecodeError
    false
  end

  def email_token_decode(token)
    JWT.decode(token, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def new_attributes
    {
      id: self.id, 
      name: self.name, 
      email: self.email,
      role: self.role.role_name
    }
  end

  def profile_attributes
    {
      id: self.id, 
      name: self.name, 
      email: self.email,
      address: self.address,
      phone_number: self.phone_number,
      avatar: self.avatar&.new_attribute
    }
  end

  def password_match?(current_password)
    return false if current_password.blank?

    if authenticate(current_password)
      true
    else
      
      errors.add(:current_password, 'tidak cocok')
      false
    end
  end

  def encode_token(payload)
    JWT.encode payload, ENV['SECRET_KEY'], 'HS256'
  end

  def resend_confirmation_email
    token_activation = generate_confirmation_token
    update_attribute(:confirm_token, token_activation)

    RegisterMailer.send_register_email(self, token_activation).deliver
  rescue => e
    Rails.logger.error "Gagal mengirim untuk email verifikasi ulang: #{e.message}"
    false
  end

  def generate_confirmation_token
    payload = { email: email }
    expired_time = 18000 * 24
    exp = Time.now.to_i + expired_time
    payload[:exp] = exp
    self.confirm_token_sent_at = Time.zone.now
    encode_token(payload)
  end

  def send_registration_email
    token_activation = generate_confirmation_token
    self.confirm_token = token_activation
    self.confirm_token_sent_at = Time.zone.now
    update_attribute(:confirm_token, token_activation)
    RegisterMailer.send_register_email(self, token_activation).deliver
  end

  def email_confirmed?
    email_confirmed
  end

  def email_unconfirmed?
    !email_confirmed
  end

  def self.create_with_params(params)
    user = User.new(register_params(params))
    if user.save
      user.send_registration_email
      return { code: 201, status: "CREATED", message: 'Anda telah berhasil mendaftar! Harap konfirmasi alamat email Anda dengan memeriksa kotak masuk Anda.', data: user }
    else
      error_messages = user.errors.messages.transform_values { |v| v.first }
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: error_messages }
    end
  end

  def self.register_params(params)
    params.permit(:name, :email, :password, :role_id)
  end

  def self.verify_account params
    return { code: 404, status: "NOT FOUND", message: "Token tidak ditemukan" } if params['token_verification'].blank?
    
    user = User.find_by(confirm_token: params['token_verification'])
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Token invalid, mohon lakukan pengiriman ulang' } if user.blank?

    # confirm_token_sent_at = Time.zone.parse(user.confirm_token_sent_at)
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email telah diverifikasi sebelumnya!' } if user.email_confirmed?
    return { code: 200, status: "OK", message: 'Verifikasi Sukses, Silahkan Login' } if user.update_attribute(:email_confirmed, true)
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Token verifikasi telah kadaluarsa' } if user.confirm_token_sent_at + 5.days < Time.now
  end

  def self.resend_token_register params
    @user = User.find_by(email: params[:email])
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email harus diisi' } if params[:email].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email tidak sesuai format' } unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    return { code: 404, status: "NOT FOUND", message: 'Akun tidak terdaftar' } if @user.nil?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email sudah terverifikasi.', data: @user.profile_attributes } if @user.email_confirmed?
    return { code: 201, status: "CREATED", message: 'Token verifikasi baru telah dikirim ke email Anda. Silakan cek email Anda dan verifikasi akun Anda.', data: @user } if @user.resend_confirmation_email
  end

  def update_profile(profile_params, avatar_params)
    # skip_password_validation = true
    if update(profile_params) && avatar.update(avatar_params)
      avatar.user_email = email
      return { code: 201, status: "CREATED", message: 'Profil berhasil diperbarui', data: profile_attributes }
    else
      error_messages = errors.messages.transform_values { |v| v.first }
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: error_messages }
    end
  end

  def remove_avatar
    if avatar.update(image: nil)
      avatar.user_email = email
      return { code: 201, status: "CREATED", message: 'Profil berhasil diperbarui', data: profile_attributes }
    else
      error_messages = errors.messages.transform_values { |v| v.first }
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: error_messages }
    end
  end

  def update_password(params)
    skip_password_validation = false
    if Session.find_by(user_id: self.id).nil?
      return { code: 401, status: "UNAUTHORIZED", message: 'Token anda tidak valid' }
    end

    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Password lama harus diisi' } if params[:current_password].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Password baru harus diisi' } if params[:password].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Password lama Anda salah' } unless password_match?(params[:current_password])
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Password baru tidak boleh sama dengan password lama' } if params[:current_password] == params[:password]

    if password_match?(params[:current_password]) && update(params.except(:current_password, :name, :email, :address))
      Session.find_by(user_id: self.id).destroy
      return { code: 201, status: "CREATED", message: 'Password berhasil diperbarui', data: profile_attributes }
    else
      error_messages = errors.messages.transform_values { |v| v.first }
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: error_messages }
    end
  end

  def create_avatar
    self.build_avatar.save
  end
  
  # def update_total_points
  #   transaction = Transaction.find_by(user_id: self.id)
  #   transaction&.calculate_total_points if transaction
  # end   

  def delete_profile
    Image.update(image: "hey", imageable_id: self.imageable_id, imageable_type: self.imageable_type)
  end

  def self.validate_user(email)
    user = find_by(email: email)
    if user&.email_confirmed?
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email telah digunakan oleh pengguna lain!' }
    elsif user&.email_unconfirmed?
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email sudah terdaftar dan belum terverifikasi, silakan cek email Anda' }
    else
      true
    end
  end

  def destroy_with_sessions(current_user)
    if current_user
      Session.where(user_id: current_user.id).delete_all
      self.destroy
      return { code: 200, status: "OK", message: 'Data pengguna berhasil dihapus' }
    else
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Gagal menghapus data pengguna' }
    end
  end
  
  def self.password_reset_params params
    @user = User.find_by(email: params[:email])
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email harus diisi' } if params[:email].blank?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email tidak sesuai format' } unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    return { code: 404, status: "NOT FOUND", message: 'Akun tidak terdaftar' } if @user.nil?
    return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Email belum terverifikasi.'} unless @user.email_confirmed?
    return true if @user.email_confirmed?
  end

  def self.generate_and_send_password_reset_email(email)
    user = User.find_by(email: email)
    if user
      user.generate_password_reset_token
      ForgotPasswordMailer.password_reset(user).deliver_now
      return { code: 200, status: "OK", message: 'Email reset password telah dikirim.', data: user }
    else
      return { code: 500, status: "INTERNAL SERVER ERROR", message: 'Terjadi kesalahan dalam mengirim email' }
    end
  end

  def self.reset_password(reset_password_token, password_params)
    user = User.find_by(reset_password_token: reset_password_token)
    if user && user.reset_password_token_sent_at >= 2.hours.ago
      if user.update(password_params)
        user.reset_password_token_used
        return { code: 201, status: "CREATED", message: 'Password berhasil diperbarui. Silahkan melakukan login kembali.'}
      else
        return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Gagal memperbarui password.', data: user.errors }
      end
    else
      return { code: 404, status: "NOT FOUND", message: 'Token tidak sesuai atau sudah kadaluwarsa.' }
    end
  end

  def self.check_reset_token(token)
    user = User.find_by(reset_password_token: token)

    if user.nil? || user.reset_password_token_sent_at.nil?
      return { code: 404, status: "NOT FOUND", message: 'Token tidak ditemukan atau expired' }
    elsif user.reset_password_token_sent_at < 2.hours.ago
      return { code: 422, status: "UNPROCESSABLE ENTITY", message: 'Token sudah kadaluwarsa' }
    else
      return { code: 200, status: "OK", message: 'Token aktif'}
    end
  end

  private
  def confirmation_token
    return unless confirm_token.blank?

    self.confirm_token = SecureRandom.urlsafe_base64.to_s
  end
end

