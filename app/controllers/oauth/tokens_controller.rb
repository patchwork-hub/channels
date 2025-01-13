# frozen_string_literal: true

class Oauth::TokensController < Doorkeeper::TokensController
  def create
    if params[:username].blank? || params[:password].blank?
      render json: { error: 'Username and password are required' }, status: 422
      return
    end

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
    user = User.find_by(email: params[:username])
    # return false unless user&.valid_password?(params[:password])

    # If the user role is a UserAdmin || nil, there will have custom logic to sign in
    if user.role.name == 'UserAdmin' || user.role&.id&.nil?
      community_admin = CommunityAdmin.find_by(account_id: user&.account_id, role: 'UserAdmin', is_boost_bot: true)
      return false if community_admin.nil?

      community = Community.find_by(id: community_admin&.patchwork_community_id)
      return false if community.nil?

      true
    end
    true
  end
end
