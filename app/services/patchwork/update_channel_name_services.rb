# frozen_string_literal: true

class Patchwork::UpdateChannelNameServices < BaseService
  def call(account, options = {})
    @account   = account
    @options   = options
    @type      = options[:type]
    update_channel_dispaly_name
  end

  private

  def update_channel_dispaly_name
    return unless @type == 'channel_feed'

    community_admin = CommunityAdmin.find_by(account_id: @account.id, is_boost_bot: true, account_status: CommunityAdmin.account_statuses["active"])
    if community_admin
      community_admin.update!(display_name: @account.display_name)
      community_admin.community.update!(name: @account.display_name, description: @account.note, avatar_image: @account.avatar_static_url, banner_image: @account.header_static_url)
    end
  end
end
