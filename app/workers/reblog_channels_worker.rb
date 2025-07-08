# frozen_string_literal: true

class ReblogChannelsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: false, dead: true

  def perform(status_id, account_id)
    admin_account = Account.find_by(id: account_id)
    community_user = User.find_by(account_id: admin_account.id)
    community_admin = CommunityAdmin.find_by(account_id: admin_account.id, is_boost_bot: true)
    admin_access_token = FetchAdminAccessTokenService.new(community_user&.id).call
    return false if admin_access_token.nil?

    ReblogRequestService.new.call(admin_access_token, status_id)

    # Reblog the status by bot if the channel_type is newsmast
    boost_by_newsmast_bot(community_admin, status_id) if community_admin&.community&.channel_type == 'newsmast'
  end

  private

  def boost_by_newsmast_bot(community_admin, status_id)
    @status = Status.find_by(id: status_id)
    return false if @status.nil? || @status.reply? || community_admin.nil?

    post_url = get_post_url
    bot_lamda_service = Patchwork::BoostLamdaNewsmastService.new
    boost_status = bot_lamda_service.boost_status(community_admin&.username, @status.id, post_url.to_s)
    return true if boost_status["statusCode"] == 200
    false
  end

  def get_post_url
    username = @status.account.pretty_acct
    "https://channel.org/@#{username}/#{@status.id}"
  end
end
