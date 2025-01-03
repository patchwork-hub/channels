require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
require 'time'
require 'eventmachine'
require 'em-http-request'
require 'digest'
require 'openssl'
require 'base64'

ACCESS_TOKEN_SCOPES = 'read write follow push'.freeze

class AdminAccountManager
  def initialize(admin_user)
    @admin_user = admin_user
  end

  def generate_admin_access_token
    access_token = get_or_create_admin_access_token
    access_token&.token || Rails.logger.error("[AdminAccountManager] Failed to generate or retrieve an access token.")
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

  def post_channel_status(access_token, status, instance_url)
    begin
      uri = URI("#{instance_url}/api/v1/statuses")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Authorization'] = "Bearer #{access_token}"
      request['Content-Type'] = 'application/json'
      request.body = { status: status }.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        Rails.logger.info "Status posted successfully! Response: #{response.body}"
        return true
      else
        Rails.logger.error "Failed to post status: Response: #{response.body}"
        return false
      end
    rescue => e
      Rails.logger.error "An unexpected error occurred while posting status: #{e.message}"
      return false
    end
  end
end

class FediBuzzToChannel
  MASTODON_INSTANCE = 'https://channel.org'.freeze
  FEDIBUZZ_API_URL = 'https://fedi.buzz/api/v1/streaming/public'.freeze
  STATUS_LIMIT = 400
  FEDIBUZZ_BOT = 'fudibuzz_bot@channel.org'.freeze

  def initialize
    @admin_user = User.find_by(email: FEDIBUZZ_BOT)

    unless @admin_user
      Rails.logger.error "Admin user with email #{FEDIBUZZ_BOT}' not found."
      exit
    end

    @admin_account_manager = AdminAccountManager.new(@admin_user)
    @admin_access_token = @admin_account_manager.generate_admin_access_token

    if @admin_access_token.nil?
      Rails.logger.error("Failed to generate or retrieve an admin access token. Can't post the status.")
      exit
    end
  end

  def process_status(status_json, processed_count)
    begin
      status = JSON.parse(status_json)
      content = status.dig('content')
      if content.present?
        stripped_content = ActionController::Base.helpers.strip_tags(content)
        if stripped_content.match(/@[\w\d]+(?:@[\w\d.-]+)?/)
          puts "Skipping status with mention: #{stripped_content}"
          return processed_count
        else
          post_result = @admin_account_manager.post_channel_status(@admin_access_token, stripped_content, MASTODON_INSTANCE)
          if post_result
            puts 'Successfully fetched status'
          else
            puts "Failed to fetch status"
          end
        end
      else
        puts "Status text not found in activity"
      end
      processed_count + 1
    rescue JSON::ParserError => e
      puts "JSON parsing error: #{e.message} - data: #{status_json}"
      processed_count
    rescue => e
      puts "Error processing status: #{e.message}"
      processed_count
    end
  end

  def stream_from_fedi_buzz
    puts 'Connecting to fedi.buzz API via SSE...'
    processed_count = 0
    EM.run do
      http = EventMachine::HttpRequest.new(FEDIBUZZ_API_URL).get(
        headers: { 'Accept' => 'text/event-stream' }
      )

      buffer = ''

      http.stream do |chunk|
        begin
          buffer += chunk
          while buffer.include?("\n\n")
            event, buffer = buffer.split("\n\n", 2)
            processed_count = process_sse_event(event, processed_count, STATUS_LIMIT)
            next unless processed_count >= STATUS_LIMIT

            puts "Reached status limit of #{STATUS_LIMIT}. Stopping."
            EM.stop
          end
        rescue => e
          puts "Error in stream: #{e.message}"
        end
      end

      http.errback do
        puts 'Error connecting to SSE endpoint'
        EM.stop
      end

      http.callback do
        puts 'Connection to SSE endpoint closed'
        EM.stop
      end

      EM.add_periodic_timer(10) do
        puts "Processed #{processed_count} statuses."
      end
    end
  end

  def process_sse_event(event_string, processed_count, status_limit)
    data_line = event_string.lines.find { |line| line.start_with?('data:') }
    return processed_count unless data_line

    data = data_line.sub('data:', '').strip
    begin
      new_processed_count = process_status(data, processed_count)
      processed_count = new_processed_count || processed_count
    rescue JSON::ParserError => e
      puts "JSON parsing error (inner data): #{e.message} - data: #{data}"
    end
    processed_count
  end
end

namespace :fedibuzz do
  desc 'Fetch and feed the public streaming API from fedi.buzz to Channel instance'
  task post_status: :environment do
    puts 'Running local test'
    FediBuzzToChannel.new.stream_from_fedi_buzz
  end
end
