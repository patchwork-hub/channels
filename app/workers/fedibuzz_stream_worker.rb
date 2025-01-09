class FedibuzzStreamWorker
  include Sidekiq::Worker

  ALLOWED_DOMAIN = 'channel.org'.freeze

  def perform
    Rails.logger.info('Starting FedibuzzStreamWorker...')
    if Rails.configuration.x.local_domain == ALLOWED_DOMAIN
      FedibuzzStreamService.new.stream_from_fedi_buzz
    else
      Rails.logger.info('FedibuzzStreamWorker skipped: Domain does not match allowed domain.')
    end
  rescue => e
    Rails.logger.error("FedibuzzStreamWorker encountered an error: #{e.message}")
  end
end
