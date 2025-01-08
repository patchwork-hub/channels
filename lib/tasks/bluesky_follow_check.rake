# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

namespace :admin do
  desc 'Sub-channel admins check and follow the bluesky bot account.'
  task follow_bluesky_bot: :environment do
    sleep(2)
    domain = ENV['WEB_DOMAIN'] || Rails.configuration.x.local_domain
    domain = domain.gsub(/:\d+$/, '')

    domain = domain.split('.').values_at(1, 2).join('.')

    channel_account = '@bsky.brid.gy@bsky.brid.gy'
    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    BlueskyAccountFollowing.new(owner_user.email, domain).follow_blueksy_bot_account(channel_account) if channel_account.present?
  end
end

class BlueskyAccountFollowing
  ACCESS_TOKEN_SCOPES = 'read write follow'

  def initialize(account_email, domain)
    @account_email = account_email
    @domain = domain
    @admin_user = find_admin_user
    @token = generate_admin_access_token if @admin_user
    Rails.logger.error("Invalid token for #{@account_email}.") unless @token
    return unless @token

    is_local = Rails.env.local?
    domain = ENV.fetch('LOCAL_DOMAIN', nil)
    raise 'LOCAL_DOMAIN is not defined.' if domain.nil?

    @api_base_url = "#{is_local ? 'http://' : 'https://'}#{domain.chomp('/')}"
  end

  def follow_blueksy_bot_account(channel_account)
    if @admin_user.nil?
      Rails.logger.error("Admin user with email #{@account_email} not found.")
      return
    end

    follow_account(channel_account)
  end

  private

  def find_admin_user
    admin_user = User.find_by(email: @account_email)
    Rails.logger.error("Admin user with email #{@account_email} not found.") if admin_user.nil?

    admin_user
  end

  def follow_account(channel_account)
    account_data = search_and_find_account(channel_account)
    if account_data
      fetch_did if follow_bluesky_bot?(account_data)
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

      saved_accounts = Account.where(username: accounts.map { |account| account['username'] })
      sleep(2) if saved_accounts.empty?
    end

    saved_accounts
  end

  def follow_bluesky_bot?(target_account)
    response = follow_account_on_api(target_account)

    if response.code == 200
      results = JSON.parse(response.body)
      Rails.logger.info("Fetched relationships: #{results}")
      true if results.last['requested'] == false && results.last['following'] == true
    else
      Rails.logger.error("Failed to fetch relationships #{target_account.username}: #{response.body}")
    end
  end

  def follow_account_on_api(target_account)
    HTTParty.get("#{@api_base_url}/api/v1/accounts/relationships",
                 query: { with_suspended: true, id: [target_account.id] },
                 headers: { 'Authorization' => "Bearer #{@token}" })
  end

  def fetch_did
    account = @admin_user&.account
    url = "https://fed.brid.gy/ap/@#{account.username}@#{@domain}"
    response = HTTParty.get(url)
    if response.code == 200
      document = Nokogiri::HTML(response.body)
      did_value = document.at_css("button[onclick*='writeText']")&.attr('onclick')
      if did_value.nil?
        Rails.logger.error('DID value not found in response.')
      else
        did_value = did_value.match(/'([^']+)'/)[1]
        Rails.logger.info("DID Value:: #{did_value}")
        did_value
      end
    else
      Rails.logger.error("Error fetching DID: #{response.code} - #{response.message}")
    end
  end

  attr_reader :api_base_url

  def generate_admin_access_token
    access_token = get_or_create_admin_access_token
    access_token&.token || Rails.logger.error('[BlueskyAccountFollowing] Failed to generate or retrieve an access token.')
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
end
