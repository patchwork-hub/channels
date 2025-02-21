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

    community_admin = CommunityAdmin.find_by(account_id: @account.id, is_boost_bot: true)
    if community_admin
      community_admin.update!(display_name: @account.display_name)
      community_admin.community.update!(name: @account.display_name)
    end
  end
end
