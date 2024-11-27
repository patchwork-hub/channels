# frozen_string_literal: true

class Api::V1::CustomPasswordsController < Api::BaseController
  skip_before_action :require_authenticated_user!
  before_action :set_user, only: [:update]

  layout 'email'
  def index
    user = User.find_by(email: params[:email])
    if user
      user.reset_password!
      CustomPasswordsMailer.with(user: user, web: params[:web].present?).reset_password_confirmation.deliver_later
    else
      render json: { error: 'Email not found!' }, status: 404
    end
  end

  def update
    # Validate presence of user and password fields
    return render_password_error(message: 'Missing required fields') unless @user && password_params[:password].present? && password_params[:password_confirmation].present?

    # Validate password confirmation mismatch
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
end
