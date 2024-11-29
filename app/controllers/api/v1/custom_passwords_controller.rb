# frozen_string_literal: true

class Api::V1::CustomPasswordsController < Api::BaseController
  skip_before_action :require_authenticated_user!
  before_action :set_user, only: [:update, :verify_otp]

  layout 'email'
  def create
    user = User.find_by(email: params[:email])
    if user
      user.reset_password!
      user.otp_secret = SecureRandom.random_number(10_000).to_s.rjust(4, '0')
      user.save!
      CustomPasswordsMailer.with(user: user).reset_password_confirmation.deliver_later
      render json: { reset_password_token: user.reload.reset_password_token }, status: 200
    else
      render json: { error: 'Email not found!' }, status: 404
    end
  end

  def verify_otp
    return render_password_error(message: 'Invalid otp!') unless @user && verify_otp?(params[:otp_secret])

    @user.update(otp_secret: nil)
    render json: { message: 'OTP verify successfully' }, status: 200
  end

  def update
    return render_password_error(message: 'Missing required fields') unless @user && password_params[:password].present? && password_params[:password_confirmation].present? && @user&.otp_secret.nil?

    return render_password_error(message: 'Password unmatch.') unless password_params[:password] == password_params[:password_confirmation]

    @user.password = password_params[:password]
    @user.save(validate: false)
    render json: { message: 'Password update successfully.' }, status: 200
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render_password_error(message: 'Password update unsuccessfully.')
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(reset_password_token: params[:id])
  end

  def render_password_error(message:)
    render json: { message: message }, status: 422
  end

  def verify_otp?(otp_secret)
    return false if @user.reset_password_sent_at.nil? || @user.reset_password_sent_at < 30.minutes.ago

    @user&.otp_secret == otp_secret
  end
end
