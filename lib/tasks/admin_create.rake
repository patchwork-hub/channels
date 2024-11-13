# frozen_string_literal: true

namespace :admin do
  desc 'Create admin account'
  task :create => :environment do
    p "Start Admin Creation"
    domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
    domain = domain.gsub(/:\d+$/, '')

    account_name = extract_account_name(domain)

    subdomain = domain.split('.').first
    domain = domain.split('.').values_at(1, 2).join('.')

    admin = create_account(account_name)

    account_email = "#{subdomain}_admin@#{domain}"
    password = "#{subdomain}-Channel@uomu82sl18s82"

    create_user(account_email, password, admin, "Owner")

    admins = JSON.parse(ENV.fetch('ADMINS', {}))
    admins.each do |admin|
      account = create_account(admin['username'], display_name: admin['display_name'])
      create_user(admin['email'], admin['password'], account, "Admin")
    end

    p "Finished Admin Creation"
  end

  def create_account(account_name, display_name: nil)
    display_name ||= account_name
    account = Account.where(username: account_name).first_or_initialize(username: account_name, display_name: display_name)
    account.save(validate: false)
    account
  end

  def create_user(account_email, password, account, role_name)
    user = User.where(email: account_email).first_or_initialize(
      email: account_email,
      password: password,
      password_confirmation: password,
      confirmed_at: Time.now.utc,
      role: UserRole.find_by(name: role_name),
      account: account,
      approved: true
    )
    user.save!

    Rails.logger.info "Created user #{user.email} successfully"
  end

  def extract_account_name(domain)
    parts = domain.split('.')
    if parts.length >= 3
      admin_name = parts[0].capitalize
      return "#{admin_name}Adm"
    else
      return 'Admin'
    end
  end
end
