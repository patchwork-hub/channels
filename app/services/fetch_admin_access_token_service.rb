# frozen_string_literal: true

class FetchAdminAccessTokenService
  ACCESS_TOKEN_SCOPES = 'read write follow'

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    fetch_access_token&.token
  end

  private

  def fetch_access_token
    doorkeeper_application = Doorkeeper::Application.first
    return unless doorkeeper_application && @user_id

    Doorkeeper::AccessToken.find_or_create_by(
      resource_owner_id: @user_id,
      application_id: doorkeeper_application&.id,
      revoked_at: nil
    ) do |token|
      token.scopes = ACCESS_TOKEN_SCOPES
    end
  end
end
