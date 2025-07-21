# frozen_string_literal: true

class ReblogChannelsService < BaseService
  def call(status)
    @status = status
    unless @status.sensitive? || @status.unlisted_visibility?
      community_admin_account_ids = CommunityAdmin.where(is_boost_bot: true, account_status: 0).pluck(:account_id)

      # Custom Channel
      process_custom_channels(community_admin_account_ids)

      # Group Channel
      process_group_channels(community_admin_account_ids)
    end
  end

  private

  def process_custom_channels(community_admin_account_ids)
    status_follower_admin_account_ids = @status.account.followers.local.channel_admins(community_admin_account_ids).pluck(:id)

    tag_ids = @status.tags.ids
    tag_follower_admin_account_ids = TagFollow.where(tag_id: tag_ids).pluck(:account_id)

    unique_admin_account_ids = (status_follower_admin_account_ids + tag_follower_admin_account_ids).uniq

    Account.where(id: unique_admin_account_ids).find_each do |admin_account|
      id = admin_account&.id
      next unless id

      community = get_community(id)
      next unless community

      content_type = community.content_type
      next unless content_type&.custom_channel?

      # Skip if the admin_account has muted the status account
      next if Mute.exists?(account_id: admin_account.id, target_account_id: @status.account.id)

      # Skip if the admin_account does not follow the status owner and the owner is a bot
      next if !status_follower_admin_account_ids.include?(admin_account.id) && @status.account.bot?

      # Skip if `and_condition?` is true and admin_account is not in both follower lists
      if content_type&.and_condition? && !(tag_follower_admin_account_ids.include?(admin_account.id) &&
                    status_follower_admin_account_ids.include?(admin_account.id))
        next
      end

      next unless valid_post_type?(community) && status_has_keyword?(@status.id, community.id, 'filter_in') && !status_has_keyword?(@status.id, community.id, 'filter_out')

      ReblogChannelsWorker.perform_async(@status.id, admin_account.id)
    end
  end

  def process_group_channels(community_admin_account_ids)
    return if @status.reply? || @status.reblog?

    community_admins = Account.where(id: community_admin_account_ids)

    group_channel_admins = community_admins.select do |admin_account|
      id = admin_account&.id
      next unless id

      community = get_community(id)
      community&.content_type&.group_channel?
    end

    group_channel_admins.each do |admin_account|
      if @status.mentioned_account?(admin_account) && @status.account.follow_account?(admin_account.id)
        Rails.logger.info '*****Checking Group Channel all conditions true *****'
        ReblogChannelsWorker.perform_async(@status.id, admin_account.id)
      end
    end
  end

  def valid_post_type?(community)
    community_post_type = fetch_community_post_type(community)

    return false unless community_post_type

    Rails.logger.info "Fetched community post type: #{community_post_type}"

    return false if all_post_types_excluded?(community_post_type)

    true if post_type_accepted?(community_post_type)
  end

  def fetch_community_post_type(community)
    community&.community_post_type
  end

  def all_post_types_excluded?(community_post_type)
    !any_post_types_included?(community_post_type)
  end

  def any_post_types_included?(community_post_type)
    community_post_type.posts? || community_post_type.reposts? || community_post_type.replies?
  end

  def post_type_accepted?(community_post_type)
    if @status.reply?
      community_post_type.replies?
    elsif @status.reblog?
      community_post_type.reposts?
    else
      community_post_type.posts?
    end
  end

  def get_community(account_id)
    Community.find_by(id: CommunityAdmin.find_by(account_id: account_id, account_status: CommunityAdmin.account_statuses["active"])&.patchwork_community_id)
  end

  def status_has_keyword?(status_id, community_id, filter_type)
    ContentFilters::BanStatusService.new.keyword_matches_in_status?(status_id, community_id, filter_type)
  end
end
