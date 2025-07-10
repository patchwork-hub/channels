# frozen_string_literal: true

class ReblogChannelsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: false, dead: true

  def perform(status_id, account_id)
    admin_account = Account.find_by(id: account_id)
    return false unless admin_account

    community_user = User.find_by(account_id: admin_account.id)
    return false unless community_user

    community_admin = CommunityAdmin.includes(:community).find_by(account_id: admin_account.id, is_boost_bot: true)
    return false unless community_admin

    admin_access_token = FetchAdminAccessTokenService.new(community_user.id).call
    return false unless admin_access_token

    community = community_admin&.community
    return false unless community

    if community&.channel_type == 'newsmast'
      # Reblog the status by bot if the channel_type is newsmast
      boost_by_newsmast_bot(community_admin, status_id)
    else
      begin
        ReblogRequestService.new.call(admin_access_token, status_id)
      rescue => e
        Rails.logger.error "ReblogRequestService failed: - #{e.message}"
        false
      end
    end
  end

  private

  def boost_by_newsmast_bot(community_admin, status_id)
    @status = Status.find_by(id: status_id)
    return false unless @status

    return false if @status.nil? || @status.reply? || community_admin.nil?

    post_url = fetch_post_url
    bot_lamda_service = Patchwork::BoostLamdaNewsmastService.new
    boost_status = bot_lamda_service.boost_status(community_admin&.username, @status.id, post_url.to_s)
    return true if boost_status['statusCode'] == 200

    false
  end

  def fetch_post_url
    username = @status.account.pretty_acct
    "https://channel.org/@#{username}/#{@status.id}"
  end
end
