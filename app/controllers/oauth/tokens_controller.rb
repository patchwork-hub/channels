# frozen_string_literal: true

class Oauth::TokensController < Doorkeeper::TokensController
  def create
    error_message = create_channel_feed? ? handle_web_login : handle_app_login

    if error_message.nil?
      super
    else
      render_error(error_message)
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
    CommunityAdmin.find_by(account_id: user.account_id, is_boost_bot: true)
  end

  def handle_web_login
    user = fetch_user_credentials
    return 'You don\'t have access to login.' if user.nil?

    return 'Organisation admin isn\'t allowed to access login.' unless user.role&.name.eql?('UserAdmin')

    nil
  end

  def handle_app_login
    user = grant_password? ? fetch_user_credentials : fetch_access_token_grant
    return 'You don\'t have access to login.' if user.nil?

    community_admin = fetch_channel_credentials(user)
    return 'Invalid credentials. Please make sure you\'ve created a channel.' if community_admin.nil?

    return 'Invalid credentials or insufficient permissions to access login.' unless valid_permissions?(community_admin, user)

    nil
  end

  # This is a solution to allow the creation of a channel feed
  def create_channel_feed?
    params[:create_channel_feed].nil? ? false : params[:create_channel_feed]
  end

  def valid_permissions?(community_admin, user)
    belong_any_channel?(community_admin) &&
      (
        (community_admin&.role.eql?('OrganisationAdmin') && user.role&.name.eql?('OrganisationAdmin')) ||
        (community_admin&.role.eql?('UserAdmin') && user.role&.name.eql?('UserAdmin'))
      )
  end

  def belong_any_channel?(community_admin)
    community = Community.where(id: community_admin.patchwork_community_id)
                         .where.not(visibility: nil)
                         .first
    community.present?
  end

  def render_error(error)
    render json: { error: error }, status: 401
  end

  def grant_password?
    params[:grant_type] == 'password'
  end

  def fetch_access_token_grant
    access_token_grant = Doorkeeper::AccessToken.find_by(token: params[:code])
    User.find_by(id: access_token_grant&.resource_owner_id)
  end
end
