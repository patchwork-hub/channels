# frozen_string_literal: true

class Patchwork::UpdateChannelNameServices < BaseService
  def call(account, options = {})
    return unless options[:type] == 'channel_feed'

    community_admin = CommunityAdmin.find_by(
      account_id: account.id,
      is_boost_bot: true,
      account_status: CommunityAdmin.account_statuses['active']
    )
    return unless community_admin

    community = community_admin.community

    community.update!(
      name: account.display_name.strip.presence,
      description: account.note,
      avatar_image: account.avatar,
      banner_image: account.header
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "[UpdateChannelNameServices] Community update failed: #{e.record.class} - #{e.message}"
  end
end
