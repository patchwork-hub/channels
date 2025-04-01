# frozen_string_literal: true

namespace :cleanup do
  desc 'Delete accounts by not reserving username and email'
  task accounts: :environment do
    # Get account IDs from command line parameter
    account_ids = []

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
  end
end
