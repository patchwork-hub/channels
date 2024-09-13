# frozen_string_literal: true

namespace :admin do
  desc 'Create 10 demo admin accounts'
  task :create_demos => :environment do
    require 'securerandom'

    domain = 'patchwork.online'
    user_role = UserRole.find_by(name: 'Owner')

    if user_role.nil?
      Rails.logger.error "UserRole 'Owner' not found"
      next
    end

    10.times do |i|
      account_name = "demo#{i + 1}"

      admin = Account.where(username: account_name.capitalize).first_or_initialize do |account|
        account.username = account_name.capitalize
      end
      admin.save(validate: false)

      account_email = "#{account_name}@#{domain}"
      password = SecureRandom.alphanumeric(8)

      user = User.where(email: account_email).first_or_initialize do |u|
        u.email = account_email
        u.password = password
        u.password_confirmation = password
        u.confirmed_at = Time.now.utc
        u.role = user_role
        u.account = admin
        u.agreement = true
        u.approved = true
      end
      user.save!
      user.approve!

      Rails.logger.info "*** Created user #{user.email} successfully with password #{password} ***"
    end
  end
end
