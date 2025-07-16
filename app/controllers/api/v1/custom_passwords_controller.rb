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

    waitlist_entry = find_waitlist_entry
    @can_register = registration_allowed?(waitlist_entry)
    return render_password_error(message: 'You\'r not allowed to register!') unless @can_register

    ActiveRecord::Base.transaction do
      handle_user_confirmation(waitlist_entry)
      handle_email_change if change_email?
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
    return render_password_error(message: 'Missing required fields.') unless @user && params[:email].present? && params[:current_password].present?

    return render_password_error(message: 'Current password is incorrect.') unless @user.valid_password?(params[:current_password])

    new_email = params[:email]

    return render_password_error(message: 'Email has already been taken.') if User.exists?(email: new_email)

    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    return render_password_error(message: 'Invalid email format.') unless new_email.match?(email_regex)

    if new_email != @user.email
      ActiveRecord::Base.transaction do
        @user.update!(
          unconfirmed_email: new_email,
          confirmation_sent_at: Time.now.utc,
          otp_secret: generate_otp_token,
          confirmed_at: nil
        )
        update_bot_email(new_email: new_email)
        log_action :change_email, @user

        # Revoke all access tokens and destroy sessions
        @user.revoke_access!
        Devise.sign_out_all_scopes ? sign_out : sign_out(@user)
        CustomPasswordsMailer.with(user: @user).reset_password_confirmation.deliver_later
      end
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

    token = Doorkeeper::AccessToken.find_by(token: params[:id])
    @user = if token
              User.find_by(id: token.resource_owner_id)
            else
              User.find_by(reset_password_token: params[:id])
            end
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

  def registration_allowed?(waitlist_entry)
    return true if reset_password? || change_email?

    return true if skip_waitlist? || params[:invitation_code].blank?

    waitlist_entry.present?
  end

  def generate_otp_token
    SecureRandom.random_number(10_000).to_s.rjust(4, '0')
  end

  def skip_waitlist?
    truthy_param?(params[:skip_waitlist])
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end

  def handle_user_confirmation(waitlist_entry)
    # This stage is known as the user was just registered
    # If confirmation_sent_at is present, that account wasn't confirmed yet!
    if @user.confirmation_sent_at.present?
      @user.account.update!(discoverable: false)
      @user.skip_confirmation!
      @user.update!(otp_secret: nil, confirmed_at: Time.now.utc, confirmation_sent_at: nil, confirmation_token: nil)
      create_useage_wait_list(waitlist_entry) if @can_register
    else
      @user.update!(otp_secret: nil)
    end
  end

  def handle_email_change
    new_email = @user.unconfirmed_email
    @user.skip_confirmation!
    @user.update!(unconfirmed_email: nil, confirmation_token: nil, confirmed_at: Time.now.utc) if @user.update(email: new_email)
  end

  def find_waitlist_entry
    return nil if skip_waitlist? || params[:invitation_code].blank?

    WaitList.find_by(invitation_code: params[:invitation_code], used: false)
  end

  def create_useage_wait_list(waitlist_entry)
    waitlist_entry.update!(used: true, account_id: @user.account.id, confirmed_at: Time.zone.now) if waitlist_entry.present?
  end

  def update_bot_email(new_email: nil)
    if defined?(CommunityAdmin) && CommunityAdmin.respond_to?(:find_by)
      community_admin = CommunityAdmin.find_by(account_id: @user&.account&.id)

      community_admin&.update!(email: new_email)
    end
  end
end
