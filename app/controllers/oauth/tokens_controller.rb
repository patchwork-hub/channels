# frozen_string_literal: true

class Oauth::TokensController < Doorkeeper::TokensController
  def create
    # You can add your own authentication logic here
    if login_from_channel?
      # Proceed with token generation
      super
    else
      render json: { error: 'Record not found' }, status: 404
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

  def login_from_channel?
    return true unless grant_password?

    user = User.find_by(email: params[:username])
    return false unless user

    return handle_user_admin_login(user) if user.role&.name == 'UserAdmin' || user.role.id == -99 || user.role.id.nil?

    true
  end

  def handle_user_admin_login(user)
    return true if create_channel_feed?

    community_admin = CommunityAdmin.find_by(account_id: user.account_id, role: 'UserAdmin', is_boost_bot: true)
    return false unless community_admin

    community = Community.find_by(id: community_admin.patchwork_community_id)
    community.present?
  end

  def create_channel_feed?
    params[:create_channel_feed].nil? ? false : params[:create_channel_feed]
  end

  def grant_password?
    params[:grant_type] == 'password'
  end
end
