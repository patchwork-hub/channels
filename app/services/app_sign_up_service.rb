# frozen_string_literal: true

class AppSignUpService < BaseService
  include RegistrationHelper

  def call(app, remote_ip, params)
    @app       = app
    @remote_ip = remote_ip
    @params    = params

    raise Mastodon::NotPermittedError unless allowed_registration?(remote_ip, invite)
    raise Mastodon::NotPermittedError unless registration_allowed

    ApplicationRecord.transaction do
      create_user!
      create_access_token!
    end

    @access_token
  end

  private

  def create_user!
    user_role = find_user_role
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

  def find_user_role
    channel_type = invitation_code_params[:channel_type].to_s
    role_name = channel_type.eql?('channel') ? 'UserAdmin' : 'HubAdmin'
    UserRole.find_by(name: role_name)
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
    @params.slice(:skip_waitlist, :invitation_code, :channel_type)
  end

  def invite_request_params
    { text: @params[:reason] }
  end

  def registration_allowed
    return true if skip_waitlist?
    
    WaitList.exists?(
      invitation_code: invitation_code_params[:invitation_code],
      used: false,
      channel_type: invitation_code_params[:channel_type]
    )
  end

  def skip_waitlist?
    truthy_param?(invitation_code_params[:skip_waitlist])
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end
end
