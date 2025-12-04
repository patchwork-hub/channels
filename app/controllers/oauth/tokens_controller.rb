# frozen_string_literal: true

class Oauth::TokensController < Doorkeeper::TokensController
  include ChannelHelper

  def create
    if main_channel?
      error_message = web_login? ? handle_web_login : handle_app_login
      if error_message.nil?
        super
      else
        render_error(error_message)
      end
    else
      super
    end
  end

  def revoke
    unsubscribe_for_token if token.present? && authorized? && token.accessible?

    super
  end

  private

  def unsubscribe_for_token
    Web::PushSubscription.where(access_token_id: token.id).delete_all
  end

  def fetch_user_credentials
    User.find_by(email: params[:username])
  end

  def fetch_channel_credentials(user)
    CommunityAdmin.joins(:community).find_by(
      account_id: user.account_id,
      is_boost_bot: true,
      account_status: CommunityAdmin.account_statuses['active'],
      community: { deleted_at: nil }
    )
  end

  def channel_active?(user)
    community_admin = CommunityAdmin.find_by(account_id: user.account_id, is_boost_bot: true)
    return true if community_admin.nil? || community_admin&.account_status == CommunityAdmin.account_statuses['active']

    return true if community_admin&.community&.deleted_at.nil?

    false
  end

  def handle_web_login
    return nil if client_credentials?

    user = fetch_user_credentials
    return 'You don\'t have access to login.' if user.nil? || user&.confirmed_at.nil?

    return "#{user.role&.name&.underscore&.humanize} isn't allowed to access login." unless user.role&.name.eql?('UserAdmin') || user.role&.name.eql?('HubAdmin') || user.role&.name.eql?('MasterAdmin')

    return 'Your channel is not active. Please contact support.' unless channel_active?(user)

    nil
  end

  def handle_app_login
    return nil if client_credentials?

    user = grant_password? ? fetch_user_credentials : fetch_access_token_grant
    return 'You don\'t have access to login.' if user.nil? # || user&.confirmed_at.nil?

    community_admin = fetch_channel_credentials(user)
    return 'Invalid credentials. Please make sure you\'ve created a channel.' if community_admin.nil?

    return 'Your account is already deleted.' if community_admin&.account_status == 'deleted'

    return 'Invalid credentials or insufficient permissions to access login.' unless valid_permissions?(community_admin, user)

    nil
  end

  # This is a solution to allow the creation of a Channel feed and Hub
  def web_login?
    truthy_param?(params[:is_web_login])
  end

  def valid_permissions?(community_admin, user)
    belong_any_channel?(community_admin) &&
      (
        (community_admin&.role.eql?('OrganisationAdmin') && user.role&.name.eql?('OrganisationAdmin')) ||
        (community_admin&.role.eql?('UserAdmin') && user.role&.name.eql?('UserAdmin')) ||
        (community_admin&.role.eql?('HubAdmin') && user.role&.name.eql?('HubAdmin'))
      )
  end

  def belong_any_channel?(community_admin)
    return false if community_admin&.patchwork_community_id.blank?

    Community.exists?(
      id: community_admin.patchwork_community_id,
      visibility: Community.visibilities.keys
    )
  end

  def render_error(error)
    render json: { error: error }, status: 401
  end

  def grant_password?
    params[:grant_type] == 'password'
  end

  def client_credentials?
    params[:grant_type] == 'client_credentials'
  end

  def authorization_code?
    params[:grant_type] == 'authorization_code'
  end

  def fetch_access_token_grant
    access_token_grant = Doorkeeper::AccessGrant.find_by(token: params[:code])
    User.find_by(id: access_token_grant&.resource_owner_id)
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end
end
