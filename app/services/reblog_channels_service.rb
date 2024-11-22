# frozen_string_literal: true

class ReblogChannelsService < BaseService
  def call(status)
    @status = status
    community_admin_infos = User.joins(:role).where(user_roles: { name: 'community-admin' })
    community_admin_account_ids = community_admin_infos.pluck(:account_id)

    # Custom Channel
    status_follower_admin_account_ids= @status.account.followers.local.channel_admins(community_admin_account_ids).pluck(:id)
    Rails.logger.info "*****STATUS_FOLLOWER_ADMIN_ACCOUNT #{status_follower_admin_account_ids}*****"

    tag_ids = @status.tags.ids
    tag_follower_admin_account_ids = TagFollow.where(tag_id: tag_ids).pluck(:account_id)
    Rails.logger.info "*****TAG_FOLLOWER_ADMIN_ACCOUNT #{tag_follower_admin_account_ids}*****"

    unique_admin_account_ids = (status_follower_admin_account_ids + tag_follower_admin_account_ids).uniq

    unique_custom_channel_admins = Account.where(id: unique_admin_account_ids).select do |admin_account|
      username = admin_account&.username
      next unless username

      community = get_community(username)
      community&.content_type&.custom_channel?
    end

    Rails.logger.info "*****UNIQUE_CUSTOM_CHANNEL_ADMIN #{unique_custom_channel_admins}*****"
    unique_custom_channel_admins.each do |admin_account|
      Rails.logger.info "*****Checking Custom Channel (Unique Admin Accounts)*****"

      community = get_community(admin_account.username)

      if community && sharable_custom_channel?(community, admin_account) && !status_banned?(@status.id, community.id)
        ReblogChannelsWorker.perform_async(@status.id, admin_account.id)
      end
    end

    #Group Channel

    community_admins = Account.where(id: community_admin_account_ids)

    group_channel_admins = community_admins.select do |admin_account|
      username = admin_account&.username
      next unless username

      community = get_community(username)
      community&.content_type&.group_channel?
    end

    group_channel_admins.each do |admin_account|
      Rails.logger.info "*****Checking Group Channel for Admin Account: #{admin_account.username}*****"

      if @status.mentioned_account?(admin_account) && @status.account.follow_account?(admin_account.id)
        ReblogChannelsWorker.perform_async(@status.id, admin_account.id)
      end
    end
  end

  private

  def sharable_custom_channel?(community, admin_account)
    Rails.logger.info "Evaluating if community #{community&.name} is sharable for admin account #{admin_account&.username}"

    community_post_type = fetch_community_post_type(community)

    if community_post_type.present?
      Rails.logger.warn "No community post type found for community #{community&.name}" unless community_post_type

      Rails.logger.info "Fetched community post type: #{community_post_type}"

      if all_post_types_excluded?(community_post_type)
        Rails.logger.warn "All post types are excluded for community #{community&.name}"
        return false
      end

      if post_type_rejected?(community_post_type)
        Rails.logger.warn "Post type rejected for community #{community&.name}"
        return false
      end
    end

    community_hashtags = fetch_community_hashtags(community)
    Rails.logger.info "Fetched community hashtags: #{community_hashtags}"

    is_tag_exists = tag_exists?(community_hashtags)
    Rails.logger.info "Tag existence check for community #{community&.name}: #{is_tag_exists}"

    custom_content_type = fetch_custom_content_type(community)
    result = evaluate_custom_condition(custom_content_type, is_tag_exists)
    Rails.logger.info "Custom condition evaluation result for community #{community&.name}: #{result}"
    result
  end


  def fetch_community_post_type(community)
    community&.community_post_types&.last
  end

  def fetch_community_hashtags(community)
    community&.community_hashtags&.pluck(:hashtag)&.map { |tag| tag.gsub('#', '') }
  end

  def fetch_custom_content_type(community)
    community&.content_type
  end

  def tag_exists?(community_hashtags)
    @status&.tags.where(name: community_hashtags).exists?
  end

  def all_post_types_excluded?(community_post_type)
    community_post_type.posts? && community_post_type.reposts? && community_post_type.replies?
  end

  def post_type_rejected?(community_post_type)
    case @status
    when @status.reply?
      community_post_type.replies?
    when @status.reblog?
      community_post_type.reposts?
    else
      community_post_type.posts?
    end
  end

  def evaluate_custom_condition(custom_content_type, is_tag_exists)
    if custom_content_type&.or_condition?
      true
    elsif custom_content_type&.and_condition?
      is_tag_exists
    else
      false
    end
  end

  def get_community(username)
    # Eg: breaking_news_channel => breaking-news
    # later we need to fix this logic, we will remove _channel from admin account
    Community.find_by(slug: username.sub('_channel', '').dasherize)
  end

  def status_banned?(status_id, community_id)
    ContentFilters::BanStatusService.new.check_and_ban_channel_status(status_id, community_id)
  end
end
