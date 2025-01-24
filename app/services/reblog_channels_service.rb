# frozen_string_literal: true

class ReblogChannelsService < BaseService
  def call(status)
    @status = status
    unless @status.sensitive? || @status.account.bot?
      community_admin_account_ids = CommunityAdmin.where(is_boost_bot: true).pluck(:account_id)

      # Custom Channel
      status_follower_admin_account_ids = @status.account.followers.local.channel_admins(community_admin_account_ids).pluck(:id)
      # Rails.logger.info "*****STATUS_FOLLOWER_ADMIN_ACCOUNT #{status_follower_admin_account_ids}*****"

      tag_ids = @status.tags.ids
      # Rails.logger.info "*****STATUS_OF_TAGS #{@status.tags.inspect}*****"
      tag_follower_admin_account_ids = TagFollow.where(tag_id: tag_ids).pluck(:account_id)
      # Rails.logger.info "*****TAG_FOLLOWER_ADMIN_ACCOUNT #{tag_follower_admin_account_ids}*****"

      unique_admin_account_ids = (status_follower_admin_account_ids + tag_follower_admin_account_ids).uniq

      Account.where(id: unique_admin_account_ids).each do |admin_account|
        Rails.logger.info "*****TAG_FOLLOWER_ADMIN #{admin_account&.username}*****" if admin_account&.username == "tech"
        id = admin_account&.id
        next unless id

        community = get_community(id)
        next unless community

        content_type = community.content_type
        next unless content_type&.custom_channel?

        # Skip if the admin_account has muted the status account
        next if Mute.exists?(account_id: admin_account.id, target_account_id: @status.account.id)

        # Skip if `and_condition?` is true and admin_account is not in both follower lists
        if content_type&.and_condition?
          next unless tag_follower_admin_account_ids.include?(admin_account.id) &&
                      status_follower_admin_account_ids.include?(admin_account.id)
        end

        if valid_post_type?(community, admin_account) && status_has_keyword?(@status.id, community.id, 'filter_in') && !status_has_keyword?(@status.id, community.id, 'filter_out')
          Rails.logger.info "*****STATUS_HAS_BEEN_SHARED_BY #{admin_account.username}*****" if admin_account&.username == "tech"
          ReblogChannelsWorker.perform_async(@status.id, admin_account.id)
        end
      end

      # Group Channel
      community_admins = Account.where(id: community_admin_account_ids)

      group_channel_admins = community_admins.select do |admin_account|
        id = admin_account&.id
        next unless id

        community = get_community(id)
        community&.content_type&.group_channel?
      end

      sleep 1.minutes
      group_channel_admins.each do |admin_account|
        Rails.logger.info "*****Checking Group Channel for Admin Account: #{admin_account.inspect}*****"
        Rails.logger.info "*****Checking Group Channel for status: #{@status.inspect}*****"
        retries = 0
        while retries < 5
          Rails.logger.info "*****Checking Group Channel (#{retries}/5) mentions: #{@status.mentions.inspect}*****"
          Rails.logger.info "*****Checking Group Channel (#{retries}/5) mention?: #{@status.mentioned_account?(admin_account)}*****"
          Rails.logger.info "*****Checking Group Channel (#{retries}/5) followings: #{@status.account.following.inspect}*****"
          Rails.logger.info "*****Checking Group Channel (#{retries}/5) follow?: #{@status.account.follow_account?(admin_account.id)}*****"

          if @status.mentioned_account?(admin_account) && @status.account.follow_account?(admin_account.id)
            Rails.logger.info '*****Checking Group Channel all conditions true *****'
            ReblogChannelsWorker.perform_async(@status.id, admin_account.id)
            break
          else
            retries += 1
            Rails.logger.info "*****Group Channel Retrying (#{retries}/5) for Admin Account: #{admin_account.username}*****"
          end
        end
      end
    end
  end

  private

  def valid_post_type?(community, admin_account)
    Rails.logger.info "Evaluating if community #{community&.name} is sharable for admin account #{admin_account&.username}"  if admin_account&.username == "tech"

    community_post_type = fetch_community_post_type(community)

    unless community_post_type
      Rails.logger.warn "No community post type found for community #{community&.name}" if admin_account&.username == "tech"
      return true
    end

    Rails.logger.info "Fetched community post type: #{community_post_type}"

    if all_post_types_excluded?(community_post_type)
      Rails.logger.warn "All post types are excluded for community #{community&.name}" if admin_account&.username == "tech"
      return false
    end

    if post_type_rejected?(community_post_type)
      Rails.logger.warn "Post type rejected for community #{community&.name}" if admin_account&.username == "tech"
      return false
    end

    true
  end

  def fetch_community_post_type(community)
    community&.community_post_type
  end

  def all_post_types_excluded?(community_post_type)
    community_post_type.posts? && community_post_type.reposts? && community_post_type.replies?
  end

  def post_type_rejected?(community_post_type)
    case
    when @status.reply? then community_post_type.replies?
    when @status.reblog? then community_post_type.reposts?
    else community_post_type.posts?
    end
  end

  def get_community(account_id)
    Community.find_by(id: CommunityAdmin.find_by(account_id: account_id)&.patchwork_community_id)
  end

  def status_has_keyword?(status_id, community_id, filter_type)
    ContentFilters::BanStatusService.new.keyword_matches_in_status?(status_id, community_id, filter_type)
  end
end
