# frozen_string_literal: true

namespace :newsmast do
  desc 'Create newsmast accounts for Newsmast Channels'
  task create_accounts: :environment do
    Rails.logger.info '=== Starting account creation process ==='

    domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
    Rails.logger.info "Using domain: #{domain}"

    newsmast_usernames = %w(nature
                            activism
                            socialsciences
                            biodiversity
                            physics
                            books
                            uspolitics
                            architecture
                            indigenouspeoples
                            breakingnews
                            ai
                            academia
                            foodanddrink
                            visualarts
                            history
                            government
                            journalismandcomment
                            womensvoices
                            football
                            biology
                            puzzles
                            ukraineinvasion
                            space
                            politics
                            markets
                            technology
                            performingarts
                            business
                            disabledvoices
                            pets
                            immigrantsrights
                            creativearts
                            chemistry
                            sport
                            democracy
                            hungerandglobalhealth
                            gaming
                            humour
                            workersrights
                            climatechange
                            engineering
                            mathematics
                            ussport
                            mentalhealth
                            philosophy
                            tvandradio
                            healthcare
                            socialmedia
                            blackvoices
                            travel
                            photography
                            lgbtq
                            movies
                            programming
                            weather
                            povertyandinequality
                            science
                            energy
                            environment
                            law
                            humanities
                            music)

    Rails.logger.info "Will attempt to create #{newsmast_usernames.count} accounts"

    created_count = 0
    skipped_count = 0
    error_count = 0

    newsmast_usernames.each_with_index do |username, index|
      Rails.logger.info "Processing [#{index + 1}/#{newsmast_usernames.count}] @#{username}"

      begin
        # Check if account already exists
        if Account.exists?(username: username, domain: nil)
          Rails.logger.info "  → Account @#{username} already exists, skipping"
          skipped_count += 1
          next
        end

        email = "#{username}@#{domain}"
        if User.exists?(email: email)
          Rails.logger.info "  → Email #{email} already in use, skipping"
          skipped_count += 1
          next
        end

        # Create account
        account = Account.new(username: username)
        account.save(validate: false)

        # Create user
        user_role = UserRole.find_by(name: 'UserAdmin')

        user = User.new(
          email: email,
          password: 'password',
          password_confirmation: 'password',
          confirmed_at: Time.now.utc,
          role: user_role,
          account: account,
          agreement: true,
          approved: true
        )

        user.save!
        user.approve!

        Rails.logger.info "  ✓ Successfully created account @#{username}"
        created_count += 1
      rescue => e
        Rails.logger.error "  ✗ Error creating account @#{username}: #{e.message}"
        error_count += 1
      end
    end

    # Summary
    Rails.logger.info '=== Account creation summary ==='
    Rails.logger.info "Total accounts processed: #{newsmast_usernames.count}"
    Rails.logger.info "Successfully created: #{created_count}"
    Rails.logger.info "Skipped (already exist): #{skipped_count}"
    Rails.logger.info "Errors: #{error_count}"
    Rails.logger.info '=== Process completed ==='
  end
end
