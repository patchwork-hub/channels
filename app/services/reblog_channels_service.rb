# frozen_string_literal: true

class ReblogChannelsService < BaseService
  def call(status)
    @status = status
    community_admin_infos = User.joins(:role).where(user_roles: { name: 'community-admin' })

    @status.account.followers.local.channel_admins(community_admin_infos.pluck(:account_id)).each do |admin_account|
      Rails.logger.info "Checking Custom Channel"
      username = admin_account&.username
      next unless username

      # Eg: breaking_news_channel => breaking-news
      community = get_community(username)

      ReblogChannelsWorker.perform_async(@status.id, admin_account.id) if community&.content_type&.custom_channel? && sharable_custom_channel?(community, admin_account)
    end

    community_admins = Account.where(id: User.joins(:role).where(user_roles: { name: 'community-admin' }).select(:account_id))
    community_admins.each do |admin_account|
      username = admin_account&.username
      next unless username

      # Eg: breaking_news_channel => breaking-news
      community = get_community(username)

      ReblogChannelsWorker.perform_async(@status.id, admin_account.id) if community&.content_type&.group_channel? && @status.mentioned_account?(admin_account) && @status.account.follow_account?(admin_account.id)
    end
  end

  private

  def sharable_custom_channel?(community, admin_account)
    Rails.logger.info "Evaluating if community #{community.id} is sharable for admin account #{admin_account.id}"

    community_post_type = fetch_community_post_type(community)
    unless community_post_type
      Rails.logger.warn "No community post type found for community #{community.id}"
      return false
    end
    Rails.logger.info "Fetched community post type: #{community_post_type}"

    community_hashtags = fetch_community_hashtags(community)
    Rails.logger.info "Fetched community hashtags: #{community_hashtags}"

    if all_post_types_excluded?(community_post_type)
      Rails.logger.warn "All post types are excluded for community #{community.id}"
      return false
    end

    is_tag_exists = tag_exists?(community_hashtags)
    logger.info "Tag existence check for community #{community.id}: #{is_tag_exists}"

    if post_type_rejected?(community_post_type)
      Rails.logger.warn "Post type rejected for community #{community.id}"
      return false
    end

    result = evaluate_custom_condition(community_post_type, is_tag_exists)
    Rails.logger.info "Custom condition evaluation result for community #{community.id}: #{result}"
    result
  end


  def fetch_community_post_type(community)
    community&.community_post_types&.last
  end

  def fetch_community_hashtags(community)
    community&.community_hashtags&.pluck(:hashtag)&.map { |tag| tag.gsub('#', '') }
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
      !community_post_type.replies?
    when @status.reblog?
      !community_post_type.reposts?
    else
      !community_post_type.posts?
    end
  end

  def evaluate_custom_condition(community_post_type, is_tag_exists)
    case community_post_type&.custom_condition
    when 'or_condition'
      true
    when 'and_condition'
      is_tag_exists
    else
      false
    end
  end

  def get_community(username)
    Community.find_by(slug: username.sub('_channel', '').dasherize)
  end
end
