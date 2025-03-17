# frozen_string_literal: true

class Api::V1::CustomPasswordsController < Api::BaseController
  ACCESS_TOKEN_SCOPES = 'read write follow push profile'
  skip_before_action :require_authenticated_user!, except: [:change_password, :change_email]
  before_action :require_authenticated_user!, only: [:change_password, :change_email]
  before_action :set_user, only: [:update, :verify_otp, :request_otp]

  include AccountableConcern
  layout 'email'

  def create
    user = User.find_by(email: params[:email])
    if user
      user.reset_password!
      user.otp_secret = generate_otp_token
      user.save!
      CustomPasswordsMailer.with(user: user).reset_password_confirmation.deliver_later
      render json: { reset_password_token: user.reload.reset_password_token }, status: 200
    else
      render json: { error: 'Email not found!' }, status: 404
    end
  end

  def update
    return render_password_error(message: 'Missing required fields') unless @user && password_params[:password].present? && password_params[:password_confirmation].present? && @user&.otp_secret.nil?

    return render_password_error(message: 'Password unmatch.') unless password_params[:password].eql?(password_params[:password_confirmation])

    @user.password = password_params[:password]
    @user.save(validate: false)
    render json: { message: 'The password has been updated.' }, status: 200
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render_password_error(message: 'The password update was unsuccessful.')
  end

  def request_otp
    if @user
      @user.otp_secret = generate_otp_token
      @user.save!
      CustomPasswordsMailer.with(user: @user).reset_password_confirmation.deliver_later
      render json: { access_token: params[:id] }, status: 200
    else
      render json: { error: 'Email not found!' }, status: 404
    end
  end

  def verify_otp
    return render_password_error(message: 'Invalid otp!') unless @user && verify_otp?(params[:otp_secret], reset_password: reset_password?)

    can_register = enable_to_access?
    return render_password_error(message: 'You\'r not allowed to register!') unless can_register

    ActiveRecord::Base.transaction do
      # This stage is known as the user was just registered
      # If confirmation_sent_at is present, that account was unconfirmed yet
      if @user.confirmation_sent_at.present?
        @user.account.update!(discoverable: false)
        @user.update!(otp_secret: nil, confirmed_at: Time.now.utc, confirmation_sent_at: nil)
        create_useage_wait_list if can_register

        if change_email?
          new_mail = @user.unconfirmed_email
          @user.skip_confirmation!
          if @user.update(email: new_mail)
            @user.unconfirmed_email = nil
            @user.confirmation_token = nil
            @user.save # Save the user with the new email
          end
        end
      else
        @user.update!(otp_secret: nil)
      end
    end
    render json: { message: generate_access_token }, status: 200
  rescue ActiveRecord::RecordInvalid => e
    render_password_error(message: e.message)
  end

  def change_password
    @user = current_user
    return render_password_error(message: 'Missing required fields') unless @user && password_params[:password].present? && password_params[:password_confirmation].present? && params[:current_password].present? && @user&.otp_secret.nil?

    return render_password_error(message: 'Current password is incorrect.') unless @user.valid_password?(params[:current_password])

    @user.password = password_params[:password]
    @user.save(validate: false)

    render json: { message: 'The password has been updated.' }, status: 200
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render_password_error(message: 'The password update was unsuccessful.')
  end

  def change_email
    @user = current_user
    return render_password_error(message: 'Missing required fields.') unless @user && params[:email].present? && params[:current_password].present? && @user&.otp_secret.nil?

    return render_password_error(message: 'Current password is incorrect.') unless @user.valid_password?(params[:current_password])

    new_email = params[:email]

    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    return render_password_error(message: 'Invalid email format.') unless new_email.match?(email_regex)

    if new_email != @user.email
      @user.update!(
        unconfirmed_email: new_email,
        confirmation_sent_at: Time.now.utc,
        otp_secret: generate_otp_token,
        confirmed_at: nil
      )

      log_action :change_email, @user

      # Revoke all access tokens and destroy sessions
      @user.revoke_access!
      Devise.sign_out_all_scopes ? sign_out : sign_out(@user)
      CustomPasswordsMailer.with(user: @user).reset_password_confirmation.deliver_later
    end

    render json: { message: generate_access_token }, status: 200
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render_password_error(message: 'The email update was unsuccessful.')
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def set_user
    return nil if params[:id].nil?

    if reset_password?
      @user = User.find_by(reset_password_token: params[:id])
    else
      token = Doorkeeper::AccessToken.find_by(token: params[:id])
      @user = User.find_by(id: token&.resource_owner_id) if token
    end
    @user
  end

  def render_password_error(message:)
    render json: { message: message }, status: 422
  end

  def verify_otp?(otp_secret, reset_password: false)
    return false if reset_password && (@user.reset_password_sent_at.nil? || @user.reset_password_sent_at < 30.minutes.ago)

    @user&.otp_secret == otp_secret
  end

  def reset_password?
    truthy_param?(params[:is_reset_password])
  end

  def change_email?
    truthy_param?(params[:is_change_email])
  end

  def generate_access_token
    access_token = Doorkeeper::AccessToken.find_or_create_by(
      resource_owner_id: @user.id,
      application_id: Doorkeeper::Application.first.id,
      revoked_at: nil
    ) do |token|
      token.scopes = ACCESS_TOKEN_SCOPES
    end

    { access_token: access_token.token,
      token_type: 'Bearer',
      scope: ACCESS_TOKEN_SCOPES,
      created_at: access_token.created_at.to_i }
  end

  def create_useage_wait_list
    wait_list = WaitList.find_by(invitation_code: params[:invitation_code], used: false)
    return unless wait_list

    wait_list.update!(used: true, account_id: @user.account.id, confirmed_at: Time.zone.now)
  end

  def enable_to_access?
    if reset_password? || change_email?
      true
    else
      skip_waitlist = params[:skip_waitlist].nil? ? 'false' : params[:skip_waitlist].to_s
      if skip_waitlist == 'true'
        true
      else
        WaitList.find_by(invitation_code: params[:invitation_code], used: false).present?
      end
    end
  end

  def generate_otp_token
    SecureRandom.random_number(10_000).to_s.rjust(4, '0')
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end
end
