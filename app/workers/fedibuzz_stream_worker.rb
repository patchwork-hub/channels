class FedibuzzStreamWorker
  include Sidekiq::Worker

  def perform
    Rails.logger.info('Starting FedibuzzStreamWorker...')
    FedibuzzStreamService.new.stream_from_fedi_buzz
  rescue => e
    Rails.logger.error("FedibuzzStreamWorker encountered an error: #{e.message}")
  end
end
