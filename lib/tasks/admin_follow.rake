# frozen_string_literal: true

require 'httparty'

namespace :admin do
  desc 'Sub-channel admins search and follow the main channel super admin account.'
  task follow: :environment do
    domain = ENV['WEB_DOMAIN'] || Rails.configuration.x.local_domain
    domain = domain.gsub(/:\d+$/, '')

    domain = domain.split('.').values_at(1, 2).join('.')

    admins = JSON.parse(ENV.fetch('ADMINS', '{}'))
    # channel_account = "@#{admins.values.first["username"]}@#{domain}"
    channel_account = "@#{admins.values.first["username"]}@channel.org"

    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    AdminAccountManager.new(owner_user.email).follow_admin_account(channel_account)

    # admins = JSON.parse(ENV.fetch('ADMINS', '{}'))
    # if admins.empty?
    #   Rails.logger.error("No admins found in the ADMINS environment variable.")
    # end

    # admins.each_value do |admin|
    #   if admin['email'].to_s.strip != ''
    #     AdminAccountManager.new(admin['email']).follow_admin_account(channel_account)
    #   end
    # end
  end
end

class AdminAccountManager
  ACCESS_TOKEN_SCOPES = 'read write follow'

  def initialize(account_email)
    @account_email = account_email
    @admin_user = find_admin_user
    @token = generate_admin_access_token if @admin_user
    return Rails.logger.error("Invalid token for #{@account_email}.") unless @token
    is_local = Rails.env.local?
    domain = ENV.fetch('LOCAL_DOMAIN', nil)
    if domain.nil?
      raise 'LOCAL_DOMAIN is not defined.'
    end

    @api_base_url = "#{is_local ? 'http://' : 'https://'}#{domain.chomp('/')}"
  end

  def follow_admin_account(channel_account)
    if @admin_user.nil?
      puts "Admin user with email #{@account_email} not found."
      Rails.logger.error("Admin user with email #{@account_email} not found.")
      return
    end

    follow_account(channel_account)
  end

  private

  def find_admin_user
    admin_user = User.find_by(email: @account_email)
    if admin_user.nil?
      Rails.logger.error("Admin user with email #{@account_email} not found.")
    end
    admin_user
  end

  def follow_account(channel_account)
    account_data = search_and_find_account(channel_account)
    if account_data
      follow_contributor!(account_data)
    else
      puts "Account #{channel_account} not found."
    end
  end

  def search_and_find_account(search_param)
    response = search_account(search_param)
    accounts = response.parsed_response['accounts']
    find_saved_accounts_with_retry(accounts).first
  end

  def search_account(query)
    HTTParty.get("#{@api_base_url}/api/v2/search",
                 query: { q: query, resolve: true, limit: 1 },
                 headers: { 'Authorization' => "Bearer #{@token}" })
  end

  def find_saved_accounts_with_retry(accounts)
    return [] unless accounts.present?

    saved_accounts = []
    while saved_accounts.empty?
      saved_accounts = Account.where(username: accounts.map { |account| account['username'] }, domain: @domain)
      sleep(2) if saved_accounts.empty?
    end

    saved_accounts
  end

  def follow_contributor!(target_account, reblogs: true)
    response = follow_account_on_api(target_account, reblogs)

    if response.code == 200
      Rails.logger.info("Successfully followed #{target_account.username}.")
    else
      Rails.logger.error("Failed to follow account #{target_account.username}: #{response.body}")
    end
  end

  def follow_account_on_api(target_account, reblogs)
    payload = { reblogs: reblogs }
    headers = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' }

    HTTParty.post("#{api_base_url}/api/v1/accounts/#{target_account.id}/follow",
                  body: payload.to_json, headers: headers)
  end

  attr_reader :api_base_url

  def generate_admin_access_token
    access_token = get_or_create_admin_access_token
    access_token&.token || log_error('Failed to generate or retrieve an access token.')
  end

  def get_or_create_admin_access_token
    Doorkeeper::AccessToken.find_or_create_by(
      resource_owner_id: @admin_user.id,
      application_id: doorkeeper_application.id,
      revoked_at: nil
    ) do |token|
      token.scopes = ACCESS_TOKEN_SCOPES
    end
  end

  def doorkeeper_application
    Doorkeeper::Application.find_or_create_by(superapp: true) do |app|
      app.name = 'Web'
      app.redirect_uri = Doorkeeper.configuration.native_redirect_uri
      app.scopes = 'read write follow push'
    end
  end

  def log_error(message)
    Rails.logger.error("[AdminAccountManager] #{message}")
    nil
  end
end
