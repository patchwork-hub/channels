require 'net/http'
require 'uri'
require 'json'
require 'eventmachine'
require 'em-http-request'

class FedibuzzStreamService < BaseService
  MASTODON_INSTANCE = 'https://channel.org'.freeze
  FEDIBUZZ_API_URL = 'https://fedi.buzz/api/v1/streaming/public'.freeze
  MASTODON_ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN'.freeze
  ACCESS_TOKEN_SCOPES = 'read write follow push'.freeze
  MASTODON_ADMIN_EMAIL = 'admin@channel.org'.freeze
  STATUS_LIMIT = 100

  def process_status(status_json, processed_count)
    begin
      status = JSON.parse(status_json)
      search_mastodon_posts(status['uri'])
      processed_count + 1
    rescue JSON::ParserError => e
      Rails.logger.debug { "JSON parsing error: #{e.message} - data: #{status_json}" }
      processed_count
    rescue => e
      Rails.logger.debug { "Error processing status: #{e.message}" }
      processed_count
    end
  end

  def search_mastodon_posts(uri)
    search_uri = URI("#{MASTODON_INSTANCE}/api/v2/search")
    search_uri.query = URI.encode_www_form({ q: uri, resolve: true })

    http = Net::HTTP.new(search_uri.host, search_uri.port)
    http.use_ssl = search_uri.scheme == 'https'
    request = Net::HTTP::Get.new(search_uri.request_uri)
    token = generate_admin_access_token
    request['Authorization'] = "Bearer #{token}"

    response = http.request(request)
    if response.code.to_i == 200
      results = JSON.parse(response.body)
      Rails.logger.debug { "Search results: #{results}" }
    else
      Rails.logger.debug { "Failed to search posts: #{response.code} - #{response.body}" }
    end
  end

  def stream_from_fedi_buzz
    Rails.logger.debug 'Connecting to fedi.buzz API via SSE...'
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

            Rails.logger.debug { "Reached status limit of #{STATUS_LIMIT}. Stopping." }
            EM.stop
          end
        rescue => e
          Rails.logger.debug { "Error in stream: #{e.message}" }
        end
      end

      http.errback do
        Rails.logger.debug 'Error connecting to SSE endpoint'
        EM.stop
      end

      http.callback do
        Rails.logger.debug 'Connection to SSE endpoint closed'
        EM.stop
      end

      EM.add_periodic_timer(10) do
        puts "Processed #{processed_count} statuses."
      end
    end
  end

  def process_sse_event(event_string, processed_count, _status_limit)
    data_line = event_string.lines.find { |line| line.start_with?('data:') }
    return processed_count unless data_line

    data = data_line.sub('data:', '').strip
    begin
      processed_count = process_status(data, processed_count)
    rescue JSON::ParserError => e
      Rails.logger.debug { "JSON parsing error (inner data): #{e.message} - data: #{data}" }
    end
    processed_count
  end

  def generate_admin_access_token
    @admin_user = User.find_by(email: MASTODON_ADMIN_EMAIL)
    access_token = get_or_create_admin_access_token
    access_token&.token || Rails.logger.error('[AdminAccountManager] Failed to generate or retrieve an access token.')
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
