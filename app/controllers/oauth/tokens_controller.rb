# frozen_string_literal: true

class Oauth::TokensController < Doorkeeper::TokensController
  # def create
  #   # You can add your own authentication logic here
  #   if login_from_channel?
  #     # Proceed with token generation
  #     super
  #   else
  #     render json: { error: 'Record not found' }, status: 404
  #   end
  # end

  # def revoke
  #   unsubscribe_for_token if token.present? && authorized? && token.accessible?

  #   super
  # end

  private

  def unsubscribe_for_token
    Web::PushSubscription.where(access_token_id: token.id).delete_all
  end

  def login_from_channel?
    if params[:grant_type].nil? ? false : params[:grant_type]
      user = User.find_by(email: params[:username])

      return true if (user.role.name == 'UserAdmin' || user.role&.id&.nil?) && is_create_channel_feed?

      # If the user role is a UserAdmin || nil, there will have custom logic to sign in
      if user.role.name == 'UserAdmin' || user.role&.id&.nil?
        community_admin = CommunityAdmin.find_by(account_id: user&.account_id, role: 'UserAdmin', is_boost_bot: true)
        return false if community_admin.nil?

        community = Community.find_by(id: community_admin&.patchwork_community_id)
        return false if community.nil?

        true
      end
    else
      true
    end
  end

  def is_create_channel_feed?
    params[:create_channel_feed].nil? ? false : params[:create_channel_feed]
  end
end
