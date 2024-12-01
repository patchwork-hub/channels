# frozen_string_literal: true

class Patchwork::Federation::SearchService < BaseService
  def call(url, account, limit, options = {})
    @url       = url
    @account   = account
    @options   = options
    @limit     = limit.to_i
    @type      = options[:type]
    @domain    = account.domain || 'channel.org'
    @access_token = options[:doorkeeper_token].token if options[:doorkeeper_token]
    call_search_api if @domain && @access_token
    @response
  end

  private

  def call_search_api
    search_endpoint = "https://#{@domain}/api/v2/search?q=#{URI.encode_www_form_component(@url)}&resolve=true&limit=1"
    headers = {
      'Authorization' => "Bearer #{@access_token}",
    }
    @response = HTTParty.get(search_endpoint, headers: headers)
  end
end
