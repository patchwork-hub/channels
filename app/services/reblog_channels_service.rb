# frozen_string_literal: true

class ReblogChannelsService < BaseService
  def call(status)
    @status = status
    community_admin_infos = User.joins(:role).where(user_roles: { name: 'community-admin' })

    @status.account.followers.local.channel_admins(community_admin_infos.pluck(:account_id)).each do |admin_account|
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
    community_post_type = fetch_community_post_type(community)
    return false unless community_post_type

    community_hashtags = fetch_community_hashtags(community)
    return false if all_post_types_excluded?(community_post_type)

    is_tag_exists = tag_exists?(community_hashtags)

    return false if post_type_rejected?(community_post_type)

    evaluate_custom_condition(community_post_type, is_tag_exists)
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
