# frozen_string_literal: true

class AppSignUpService < BaseService
  include RegistrationHelper

  USER_ADMIN_ROLE_NAME = 'UserAdmin'
  HUB_ADMIN_ROLE_NAME  = 'HubAdmin'

  def call(app, remote_ip, params)
    @app       = app
    @remote_ip = remote_ip
    @params    = params

    waitlist_entry = find_waitlist_entry
    raise Mastodon::NotPermittedError unless allowed_registration?(remote_ip, invite)
    raise Mastodon::NotPermittedError unless registration_allowed?(waitlist_entry)

    ApplicationRecord.transaction do
      create_user!(waitlist_entry)
      create_access_token!
    end

    @access_token
  end

  private

  def create_user!(waitlist_entry)
    user_role = determine_user_role(waitlist_entry)
    @user = User.create!(
      user_params.merge(
        role_id: user_role&.id,
        created_by_application: @app,
        sign_up_ip: @remote_ip,
        password_confirmation: user_params[:password],
        account_attributes: account_params,
        invite_request_attributes: invite_request_params
      )
    )
  end

  def create_access_token!
    @access_token = Doorkeeper::AccessToken.create!(
      application: @app,
      resource_owner_id: @user.id,
      scopes: @app.scopes,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
    )
  end

  def determine_user_role(waitlist_entry)
    role_name = USER_ADMIN_ROLE_NAME # Default role

    if invitation_code_params[:invitation_code].present? && waitlist_entry
      case waitlist_entry.channel_type.to_s
      when 'channel' then role_name = USER_ADMIN_ROLE_NAME
      when 'hub'     then role_name = HUB_ADMIN_ROLE_NAME
      end
    end

    UserRole.find_by!(name: role_name)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("UserRole '#{role_name}' not found. Please ensure all required UserRoles are present in the database.")
    raise "Critical: Missing UserRole '#{role_name}'"
  end

  def invite
    Invite.find_by(code: @params[:invite_code]) if @params[:invite_code].present?
  end

  def user_params
    @params.slice(:email, :password, :agreement, :locale, :time_zone, :invite_code)
  end

  def account_params
    @params.slice(:username)
  end

  def invitation_code_params
    @params.slice(:skip_waitlist, :invitation_code)
  end

  def invite_request_params
    { text: @params[:reason] }
  end

  def registration_allowed?(waitlist_entry)
    return true if skip_waitlist? || invitation_code_params[:invitation_code].blank?

    waitlist_entry.present?
  end

  def skip_waitlist?
    truthy_param?(invitation_code_params[:skip_waitlist])
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end

  def find_waitlist_entry
    return nil if skip_waitlist? || invitation_code_params[:invitation_code].blank?

    WaitList.find_by(invitation_code: invitation_code_params[:invitation_code], used: false)
  end
end
