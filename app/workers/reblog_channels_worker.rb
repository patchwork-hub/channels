# frozen_string_literal: true

class ReblogChannelsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: false, dead: true

  def perform(status_id, account_id)
    admin_account = Account.find_by(id: account_id)
    community_user = User.find_by(account_id: admin_account.id)
    admin_access_token = FetchAdminAccessTokenService.new(community_user&.id).call
    return false if admin_access_token.nil?

    ReblogRequestService.new.call(admin_access_token, status_id)
  end
end
