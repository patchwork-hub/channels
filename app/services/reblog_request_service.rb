# frozen_string_literal: true

class ReblogRequestService < BaseService
  require 'net/http'

  def call(access_token, status_id)
    url = Rails.env.development? ? URI("http://localhost:3000/api/v1/statuses/#{status_id}/reblog") : URI("https://channel.org/api/v1/statuses/#{status_id}/reblog")

    req = Net::HTTP::Post.new(url)
    req.content_type = 'application/json'
    req['Authorization'] = "Bearer #{access_token}"
    req.body = { visibility: 'public' }.to_json

    response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
      http.request(req)
    end

    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    else
      raise "Reblog creation failed: #{response.body}"
    end
  end

end
