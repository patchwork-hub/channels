# frozen_string_literal: true

module ChannelHelper
  def main_channel?
    if Rails.env.local? || Rails.env.test?
      return true
    end
    ENV.fetch('MAIN_CHANNEL', nil) != nil && ENV.fetch('MAIN_CHANNEL', nil) != 'false'
  end
end
