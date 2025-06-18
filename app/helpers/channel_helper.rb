# frozen_string_literal: true

module ChannelHelper
  def main_channel?
    ENV.fetch('MAIN_CHANNEL', nil) != nil && ENV.fetch('MAIN_CHANNEL', nil) != 'false'
  end
end
