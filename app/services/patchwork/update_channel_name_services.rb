# frozen_string_literal: true

class Patchwork::UpdateChannelNameServices < BaseService
  def call(account, options = {})
    @account   = account
    @options   = options
    @type      = options[:type]
    update_channel_display_name
  end

  private

  def update_channel_display_name
    return unless @type == 'channel_feed'

    community_admin = CommunityAdmin.find_by(
      account_id: @account.id,
      is_boost_bot: true,
      account_status: CommunityAdmin.account_statuses["active"]
    )

    return unless community_admin

    community_admin.update!(display_name: @account.display_name)
    community_admin.community.update!(
      name: @account.display_name,
      description: @account.note,
      avatar_image: @account.avatar_original_url,
      banner_image: @account.header_original_url
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Community update failed: #{e.message}"
  end
end
