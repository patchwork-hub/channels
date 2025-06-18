# frozen_string_literal: true

class UpdateAccountService < BaseService
  def call(account, params, raise_error: false)
    was_locked    = account.locked
    update_method = raise_error ? :update! : :update

    validate_account!(account) if main_channel?

    account.send(update_method, params).tap do |ret|
      next unless ret

      authorize_all_follow_requests(account) if was_locked && !account.locked
      check_links(account)
      process_hashtags(account)
    end
  rescue Mastodon::DimensionsValidationError, Mastodon::StreamValidationError => e
    account.errors.add(:avatar, e.message)
    false
  end

  private

  def authorize_all_follow_requests(account)
    follow_requests = FollowRequest.where(target_account: account)
    follow_requests = follow_requests.preload(:account).reject { |req| req.account.silenced? }
    AuthorizeFollowWorker.push_bulk(follow_requests, limit: 1_000) do |req|
      [req.account_id, req.target_account_id]
    end
  end

  def check_links(account)
    return unless account.fields.any?(&:requires_verification?)

    VerifyAccountLinksWorker.perform_async(account.id)
  end

  def process_hashtags(account)
    account.tags_as_strings = Extractor.extract_hashtags(account.note)
  end

  def validate_account!(account)
    community_admin = CommunityAdmin.find_by(account_id: account.id, is_boost_bot: true, account_status: CommunityAdmin.account_statuses["active"])
    raise Mastodon::NotPermittedError if community_admin && (community_admin.role != 'UserAdmin')
  end

  def main_channel?
    ENV.fetch('MAIN_CHANNEL', nil) != nil && ENV.fetch('MAIN_CHANNEL', nil) != 'false'
  end
end
