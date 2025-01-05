require 'net/http'
require 'uri'
require 'json'
require 'eventmachine'
require 'em-http-request'

class FedibuzzStreamer
  MASTODON_INSTANCE = 'https://channel.org'.freeze
  FEDIBUZZ_API_URL = 'https://fedi.buzz/api/v1/streaming/public'.freeze
  MASTODON_ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN'.freeze
  STATUS_LIMIT = 400

  def process_status(status_json, processed_count)
    begin
      status = JSON.parse(status_json)
      search_mastodon_posts(status['uri'])
      processed_count + 1
    rescue JSON::ParserError => e
      puts "JSON parsing error: #{e.message} - data: #{status_json}"
      processed_count
    rescue => e
      puts "Error processing status: #{e.message}"
      processed_count
    end
  end

  def search_mastodon_posts(uri)
    search_uri = URI("#{MASTODON_INSTANCE}/api/v2/search")
    search_uri.query = URI.encode_www_form({ q: uri, resolve: true })

    http = Net::HTTP.new(search_uri.host, search_uri.port)
    http.use_ssl = search_uri.scheme == 'https'
    request = Net::HTTP::Get.new(search_uri.request_uri)
    request['Authorization'] = "Bearer #{MASTODON_ACCESS_TOKEN}"

    response = http.request(request)
    if response.code.to_i == 200
      results = JSON.parse(response.body)
      puts "Search results: #{results}"
    else
      puts "Failed to search posts: #{response.code} - #{response.body}"
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

  def lambda_handler(event: {}, context: {})
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
