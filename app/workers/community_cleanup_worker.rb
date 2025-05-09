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
          account_id = community.community_admins.last&.account_id

          Rails.logger.info "[CommunityCleanupWorker] Deleting community ##{community.id}..."
          community.destroy

          if account_id && Account.exists?(account_id)
            Admin::AccountDeletionWorker.perform_async(account_id, {
              'reserve_username' => false,
              'reserve_email' => false
            })

            Rails.logger.info "[CommunityCleanupWorker] Queued account ##{account_id} for deletion."
            sleep(0.05)
          end
        end
      rescue => e
        Rails.logger.error "[CommunityCleanupWorker] Error deleting community #{community.id}: #{e.message}"
      end
    end

    Rails.logger.info "[CommunityCleanupWorker] Cleanup completed."
  end
end
