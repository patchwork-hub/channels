# frozen_string_literal: true

require 'httparty'

namespace :admin do
  desc 'Sub-channel admins search and follow the main channel super admin account.'
  task follow: :environment do
    puts "[admin:follow] Task started at #{Time.current}"
    sleep(2)

    domain = ENV['WEB_DOMAIN'] || Rails.configuration.x.local_domain
    puts "[admin:follow] Initial domain: #{domain}"

    domain = domain.gsub(/:\d+$/, '')
    puts "[admin:follow] Domain after removing port: #{domain}"

    domain = domain.split('.').values_at(1, 2).join('.')
    puts "[admin:follow] Final domain after extraction: #{domain}"

    admins = JSON.parse(ENV.fetch('ADMINS', '{}'))
    puts "[admin:follow] Parsed admins: #{admins.inspect}"

    channel_account = "@#{admins&.values&.first&.[]('username')}@#{domain}"
    puts "[admin:follow] Channel account to follow: #{channel_account}"

    owner_role = UserRole.find_by(name: 'Owner')
    puts "[admin:follow] Owner role found: #{owner_role.inspect}"

    owner_user = User.find_by(role: owner_role)
    puts "[admin:follow] Owner user found: #{owner_user&.email}"

    if channel_account.present? && owner_user.present?
      puts '[admin:follow] Proceeding with follow action'
      AdminAccountManager.new(owner_user.email, domain).follow_admin_account(channel_account)
    else
      puts "[admin:follow] Skipped: channel_account.present? = #{channel_account.present?}, owner_user.present? = #{owner_user.present?}"
    end
    puts "[admin:follow] Task completed at #{Time.current}"
  end
end

class AdminAccountManager
  ACCESS_TOKEN_SCOPES = 'read write follow'

  def initialize(account_email, domain)
    puts "[AdminAccountManager] Initializing with email: #{account_email}, domain: #{domain}"
    @account_email = account_email
    @domain = domain
    @admin_user = find_admin_user
    puts "[AdminAccountManager] Admin user found: #{@admin_user.inspect}"

    @token = generate_admin_access_token if @admin_user
    puts "[AdminAccountManager] Access token generated: #{@token.present?}"
    raise "Invalid token for #{@account_email}." unless @token

    is_local = Rails.env.local?
    puts "[AdminAccountManager] is_local: #{is_local}, Rails.env: #{Rails.env}"

    domain = ENV.fetch('LOCAL_DOMAIN', nil)
    puts "[AdminAccountManager] LOCAL_DOMAIN from ENV: #{domain.inspect}"
    raise 'LOCAL_DOMAIN is not defined.' if domain.nil?

    @api_base_url = "#{is_local ? 'http://' : 'https://'}#{domain.chomp('/')}"
    puts "[AdminAccountManager] API base URL: #{@api_base_url}"
  end

  def follow_admin_account(channel_account)
    puts "[AdminAccountManager#follow_admin_account] Starting with channel_account: #{channel_account}"
    if @admin_user.nil?
      Rails.logger.error("Admin user with email #{@account_email} not found.")
      puts '[AdminAccountManager#follow_admin_account] Error: Admin user not found'
      return
    end

    follow_account(channel_account)
  end

  private

  def find_admin_user
    puts "[AdminAccountManager#find_admin_user] Searching for user with email: #{@account_email}"
    admin_user = User.find_by(email: @account_email)
    if admin_user.nil?
      Rails.logger.error("Admin user with email #{@account_email} not found.")
      puts '[AdminAccountManager#find_admin_user] User not found!'
    else
      puts "[AdminAccountManager#find_admin_user] User found: #{admin_user.inspect}"
    end
    admin_user
  end

  def follow_account(channel_account)
    puts "[AdminAccountManager#follow_account] Searching for account: #{channel_account}"
    account_data = search_and_find_account(channel_account)
    puts "[AdminAccountManager#follow_account] Account data found: #{account_data.inspect}"

    if account_data
      follow_contributor!(account_data)
    else
      puts "[AdminAccountManager#follow_account] Account #{channel_account} not found."
    end
  end

  def search_and_find_account(search_param)
    puts "[AdminAccountManager#search_and_find_account] Searching for: #{search_param}"
    response = search_account(search_param)
    puts "[AdminAccountManager#search_and_find_account] Search response status: #{response.code}"
    puts "[AdminAccountManager#search_and_find_account] Search response: #{response.parsed_response.inspect}"

    accounts = response.parsed_response['accounts']
    puts "[AdminAccountManager#search_and_find_account] Accounts in response: #{accounts.inspect}"

    result = find_saved_accounts_with_retry(accounts).first
    puts "[AdminAccountManager#search_and_find_account] Final result: #{result.inspect}"
    result
  end

  def search_account(query)
    puts "[AdminAccountManager#search_account] Making API call to #{@api_base_url}/api/v2/search with query: #{query}"
    response = HTTParty.get("#{@api_base_url}/api/v2/search",
                            query: { q: query, resolve: true, limit: 1 },
                            headers: { 'Authorization' => "Bearer #{@token}" })
    puts "[AdminAccountManager#search_account] API response code: #{response.code}"
    response
  end

  def find_saved_accounts_with_retry(accounts)
    puts "[AdminAccountManager#find_saved_accounts_with_retry] Starting with accounts: #{accounts.inspect}"
    return [] if accounts.blank?

    saved_accounts = []
    attempts = 0
    while saved_accounts.empty?
      attempts += 1
      puts "[AdminAccountManager#find_saved_accounts_with_retry] Attempt #{attempts}: Searching for usernames: #{accounts.pluck('username').inspect}, domain: #{@domain}"
      saved_accounts = Account.where(username: accounts.pluck('username'), domain: @domain)
      puts "[AdminAccountManager#find_saved_accounts_with_retry] Found #{saved_accounts.count} accounts"

      if saved_accounts.empty?
        puts '[AdminAccountManager#find_saved_accounts_with_retry] No accounts found, sleeping 2 seconds...'
        sleep(2)
      end
    end

    puts "[AdminAccountManager#find_saved_accounts_with_retry] Final saved_accounts: #{saved_accounts.inspect}"
    saved_accounts
  end

  def follow_contributor!(target_account, reblogs: true)
    puts "[AdminAccountManager#follow_contributor!] Following account: #{target_account.inspect}"
    response = follow_account_on_api(target_account, reblogs)
    puts "[AdminAccountManager#follow_contributor!] Follow response code: #{response.code}"

    if response.code == 200
      Rails.logger.info("**********Successfully followed********** #{target_account.inspect}.")
      puts '[AdminAccountManager#follow_contributor!] Successfully followed!'
    else
      Rails.logger.error("Failed to follow account #{target_account.username}: #{response.body}")
      puts "[AdminAccountManager#follow_contributor!] Failed to follow. Status: #{response.code}, Body: #{response.body}"
    end
  end

  def follow_account_on_api(target_account, reblogs)
    puts "[AdminAccountManager#follow_account_on_api] Making follow API call for account ID: #{target_account.id}"
    payload = { reblogs: reblogs }
    headers = { 'Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json' }

    url = "#{api_base_url}/api/v1/accounts/#{target_account.id}/follow"
    puts "[AdminAccountManager#follow_account_on_api] POST to: #{url}"
    puts "[AdminAccountManager#follow_account_on_api] Payload: #{payload.inspect}"

    response = HTTParty.post(url, body: payload.to_json, headers: headers)
    puts "[AdminAccountManager#follow_account_on_api] Response: #{response.inspect}"
    response
  end

  attr_reader :api_base_url

  def generate_admin_access_token
    puts '[AdminAccountManager#generate_admin_access_token] Generating access token'
    access_token = find_or_create_admin_access_token
    puts "[AdminAccountManager#generate_admin_access_token] Access token found/created: #{access_token.inspect}"

    token = access_token&.token
    puts "[AdminAccountManager#generate_admin_access_token] Token: #{token.present? ? 'present' : 'missing'}"

    token || Rails.logger.error('[AdminAccountManager] Failed to generate or retrieve an access token.')
  end

  def find_or_create_admin_access_token
    puts "[AdminAccountManager#find_or_create_admin_access_token] Looking for token with resource_owner_id: #{@admin_user.id}"
    doorkeeper_app = doorkeeper_application
    puts "[AdminAccountManager#find_or_create_admin_access_token] Doorkeeper app: #{doorkeeper_app.inspect}"

    Doorkeeper::AccessToken.find_or_create_by(
      resource_owner_id: @admin_user.id,
      application_id: doorkeeper_app.id,
      revoked_at: nil
    ) do |token|
      token.scopes = ACCESS_TOKEN_SCOPES
      puts "[AdminAccountManager#find_or_create_admin_access_token] Created new token with scopes: #{ACCESS_TOKEN_SCOPES}"
    end
  end

  def doorkeeper_application
    puts '[AdminAccountManager#doorkeeper_application] Finding or creating Doorkeeper application'
    app = Doorkeeper::Application.find_or_create_by(superapp: true) do |app|
      app.name = 'Web'
      app.redirect_uri = Doorkeeper.configuration.native_redirect_uri
      app.scopes = 'read write follow push'
      puts '[AdminAccountManager#doorkeeper_application] Created new Doorkeeper app'
    end
    puts "[AdminAccountManager#doorkeeper_application] Doorkeeper app: #{app.inspect}"
    app
  end
end
