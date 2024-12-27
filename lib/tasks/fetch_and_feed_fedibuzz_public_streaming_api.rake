require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
require 'time'
require 'eventmachine'
require 'em-http-request'

class FedibuzzStreamer
  MASTODON_INSTANCE = 'https://channel.org'.freeze
  MASTODON_ACCESS_TOKEN = 'MASTODON_TOKEN'.freeze
  FEDIBUZZ_API_URL = 'https://fedi.buzz/api/v1/streaming/public'.freeze
  STATUS_LIMIT = 400

  def generate_activity_id
    "urn:uuid:#{SecureRandom.uuid}"
  end

  def generate_actor_id(acct)
    return unless acct.include?('@')

    username, domain = acct.split('@')
    "https://#{domain}/users/#{username}"
  end

  def create_activitypub_object(status)
    acct = status['account']['acct']
    actor_id = generate_actor_id(acct)
    activity_id = generate_activity_id

    published = status.fetch('created_at', Time.now.utc.iso8601)
    content = status['content']

    content = "<details><summary>#{status['spoiler_text']}</summary>#{content}</details>" if status['spoiler_text'].present?

    {
      id: activity_id,
      type: 'Create',
      actor: actor_id,
      published: published,
      object: {
        id: status['url'],
        type: 'Note',
        content: content,
        published: published,
        to: ['https://www.w3.org/ns/activitystreams#Public'],
        cc: [actor_id, 'https://www.w3.org/ns/activitystreams#Public'],
      },
      to: ['https://www.w3.org/ns/activitystreams#Public'],
    }
  end

  def process_status(status_json, processed_count)
    begin
      status = JSON.parse(status_json)

      activity = create_activitypub_object(status)
      puts "Created the activity #{activity}"
      uri = URI("#{MASTODON_INSTANCE}/inbox")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = activity.to_json
      request['Content-Type'] = 'application/activity+json'
      request['Authorization'] = "Bearer #{MASTODON_ACCESS_TOKEN}"

      response = http.request(request)
      if response.code.to_i == 202
        puts 'Successfully injected status'
      else
        puts "Failed to inject status: #{response.code} - #{response.body}"
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

  def stream_from_fedi_buzz(status_limit)
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
            processed_count = process_sse_event(event, processed_count, status_limit)
            next unless processed_count >= status_limit

            puts "Reached status limit of #{status_limit}. Stopping."
            EM.stop
            break
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
      processed_count = process_status(data, processed_count)
    rescue JSON::ParserError => e
      puts "JSON parsing error (inner data): #{e.message} - data: #{data}"
    end
    processed_count
  end

  def lambda_handler(_event:, _context:)
    puts 'Starting Lambda execution...'
    stream_from_fedi_buzz(STATUS_LIMIT)
  end
end

namespace :stream do
  desc 'Fetch and feed the public streaming API from fedi.buzz to Channel instance'
  task public_posts: :environment do
    FedibuzzStreamer.new.lambda_handler(event: {}, context: {})
  end
end
