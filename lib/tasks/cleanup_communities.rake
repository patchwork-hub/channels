# lib/tasks/cleanup.rake

namespace :cleanup do
  desc "Deletes communities, associated users, accounts and community admins"
  task :communities, [:ids] => :environment do |t, args|
    community_ids = (args[:ids] || "").split(",").map(&:strip).map(&:to_i)

    # Get account IDs from command line parameter
    account_ids = []

    puts "Starting community cleanup process for #{community_ids.size} communities..."

    community_ids.each do |id|
      community = Community.find_by(id: id)

      if community.nil?
        puts "Community with ID: #{id} not found. Skipping..."
        next
      end

      puts "Processing community: #{community.id}..."

      begin
        ActiveRecord::Base.transaction do
          account_ids << community&.community_admins&.last&.account_id
          puts "Deleting community with ID: #{community.id}..."
          community.destroy
        end
        puts "Successfully deleted community #{community.id}"
      rescue StandardError => e
        puts "Error deleting community #{community.id}: #{e.message}"
      end
    end

    puts "Preparing to delete #{account_ids.count} accounts"

    # Verify accounts exist
    existing_ids = Account.where(id: account_ids).pluck(:id)
    missing_ids = account_ids - existing_ids

    puts "Warning: #{missing_ids.count} accounts not found: #{missing_ids.join(', ')}" if missing_ids.any?

    # Process accounts
    existing_ids.each_with_index do |id, index|
      account = Account.find(id)
      puts "[#{index + 1}/#{existing_ids.size}] Deleting account ##{id} (@#{account.username})"

      # Queue deletion job
      Admin::AccountDeletionWorker.perform_async(id, { 'reserve_username' => false, 'reserve_email' => false })

      # Brief pause to prevent overwhelming Sidekiq
      sleep(0.05)
    end

    puts "All #{existing_ids.count} account deletion jobs have been queued"
    puts 'Monitor Sidekiq dashboard to track progress'

    puts "Community cleanup process complete."
  end
end
