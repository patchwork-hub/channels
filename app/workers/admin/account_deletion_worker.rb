# frozen_string_literal: true

class Admin::AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.week.to_i

  def perform(account_id, options = {})
    # Convert string keys to symbols since Sidekiq serializes hash keys as strings
    options = options.transform_keys(&:to_sym) if options.is_a?(Hash)

    # Set defaults if options not provided
    reserve_username = options.key?(:reserve_username) ? options[:reserve_username] : true
    reserve_email = options.key?(:reserve_email) ? options[:reserve_email] : true

    DeleteAccountService.new.call(
      Account.find(account_id),
      reserve_username: reserve_username,
      reserve_email: reserve_email
    )
  rescue ActiveRecord::RecordNotFound
    true
  end
end
