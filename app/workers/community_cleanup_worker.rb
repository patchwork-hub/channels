class CommunityCleanupWorker
  include Sidekiq::Worker

  def perform
    communities = Community.where.not(deleted_at: nil)
                           .where('deleted_at <= ?', 30.days.ago)

    if communities.empty?
      Rails.logger.info "[CommunityCleanupWorker] No communities to clean up."
      return
    end

    Rails.logger.info "[CommunityCleanupWorker] Starting cleanup for #{communities.count} communities..."

    communities.find_each do |community|
      begin
        ActiveRecord::Base.transaction do
          account_ids = community&.community_admins.pluck(:account_id)

          Rails.logger.info "[CommunityCleanupWorker] Deleting community ##{community.id}..."
          community.destroy

          account_ids.compact.uniq.each do |account_id|
            if Account.exists?(account_id)
              Admin::AccountDeletionWorker.perform_async(account_id, {
                'reserve_username' => false,
                'reserve_email' => false
              })
              Rails.logger.info "[CommunityCleanupWorker] Enqueued deletion for account ##{account_id}."
            else
              Rails.logger.warn "[CommunityCleanupWorker] Account ##{account_id} not found. Skipping deletion."
            end
          end
          sleep(0.05)
        end
      rescue => e
        Rails.logger.error "[CommunityCleanupWorker] Error deleting community #{community.id}: #{e.message}"
      end
    end

    Rails.logger.info "[CommunityCleanupWorker] Cleanup completed."
  end
end
