# frozen_string_literal: true

namespace :admin do
  desc 'Create admin account'
  task :create => :environment do
    p "Start Admin Creation"
    domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
    domain = domain.gsub(/:\d+$/, '')

    account_name = extract_account_name(domain)

    subdomain = domain.split('.').first.underscore
    domain = domain.split('.').values_at(1, 2).join('.')

    Chewy.strategy(:bypass) do
      admin = create_or_update_account(account_name)

      # account_email = "#{subdomain}_admin@#{domain}"
      account_email = "subdomain_admin@domain.org"
      password = "#{subdomain}-Channel@uomu82sl18s82"

      create_or_update_user(account_email, password, admin, "Owner")

      admins = JSON.parse(ENV.fetch('ADMINS', '{}'))
      admins.each_value do |admin_data|
        next if admin_data['username'].to_s.strip.empty?

        account = create_or_update_account(admin_data['username'], display_name: admin_data['display_name'])
        create_or_update_user(admin_data['email'], admin_data['password'], account, "Admin")
      end
    end

    p "Finished Admin Creation"
  end

  def create_or_update_account(account_name, display_name: nil)
    display_name ||= account_name
    account = Account.where(username: account_name).first_or_initialize
    account.display_name = display_name
    account.save!(validate: false)
    account
  end

  def create_or_update_user(account_email, password, account, role_name)
    user = User.where(email: account_email).first_or_initialize
    user.assign_attributes(
      password: password,
      password_confirmation: password,
      confirmed_at: Time.now.utc,
      role: UserRole.find_by(name: role_name),
      account: account,
      agreement: true,
      approved: true
    )
    user.save!
    user.approve! if user.respond_to?(:approve!)

    Rails.logger.info "Processed user #{user.email} successfully"
  end

  def extract_account_name(domain)
    parts = domain.split('.')
    if parts.length >= 3
      admin_name = parts[0].capitalize.underscore
      "#{admin_name}Adm"
    else
      'Admin'
    end
  end
end
