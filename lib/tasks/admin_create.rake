# frozen_string_literal: true

namespace :admin do
  desc 'Create admin account'
  task create: :environment do
    p 'Start Admin Creation'

    domain = ENV.fetch('LOCAL_DOMAIN', nil) || Rails.configuration.x.local_domain

    account_name = "#{domain.split('.').first.underscore.capitalize}Adm"

    Chewy.strategy(:bypass) do
      admin = create_or_update_account(account_name)

      account_email = domain.sub('.', '@')
      password = ENV.fetch('OWNER_PASSWORD', nil).to_s

      create_or_update_user(account_email, password, admin, 'Owner')

      admins = JSON.parse(ENV.fetch('ADMINS', '{}'))
      admins.each_value do |admin_data|
        next if admin_data['username'].to_s.strip.empty?

        account = create_or_update_account(admin_data['username'], display_name: admin_data['display_name'])
        create_or_update_user(admin_data['email'], admin_data['password'], account, 'Admin')
      end
    end

    p 'Finished Admin Creation'
  end

  def create_or_update_account(account_name, display_name: nil)
    display_name ||= account_name
    account = Account.where(username: account_name).first_or_initialize

    if account.new_record?
      account.display_name = display_name
      account.username = account_name
      account.save(validate: false)
    else
      account.update(display_name: display_name)
    end

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
end
