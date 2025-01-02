# frozen_string_literal: true

class ActivityPub::InboxesController < ActivityPub::BaseController
  include JsonLdHelper

  before_action :skip_unknown_actor_activity
  before_action :require_actor_signature!
  skip_before_action :authenticate_user!

  def create
    Rails.logger.info 'INBOX: Received a new request'
    Rails.logger.debug "INBOX: Request Headers: #{request.headers.to_h}"
    Rails.logger.debug "INBOX: Request Body: #{body}"

    Rails.logger.info 'INBOX: Attempting upgrade_account'
    upgrade_account
    Rails.logger.info 'INBOX: Successfully completed upgrade_account'

    Rails.logger.info 'INBOX: Attempting process_collection_synchronization'
    process_collection_synchronization
    Rails.logger.info 'INBOX: Successfully completed process_collection_synchronization'

    Rails.logger.info 'INBOX: Attempting process_payload'
    process_payload
    Rails.logger.info 'INBOX: Successfully completed process_payload'

    head 202
    Rails.logger.info 'INBOX: Request completed with 202'
  end

  private

  def skip_unknown_actor_activity
    Rails.logger.info "INBOX: Checking for skip_unknown_actor_activity"
    if unknown_affected_account?
      Rails.logger.warn "INBOX: Skipping unknown actor activity"
      head 202
    end
  end

  def unknown_affected_account?
    json = Oj.load(body, mode: :strict)
    if json.is_a?(Hash) && %w(Delete Update).include?(json['type']) && json['actor'].present? && json['actor'] == value_or_id(json['object']) && !Account.exists?(uri: json['actor'])
      Rails.logger.warn "INBOX: *****UNKNOWN_AFFECTED_ACCOUNT*****: #{json}"
      true
    else
      false
    end
  rescue Oj::ParseError => e
      Rails.logger.warn "INBOX: Oj::ParseError in unknown_affected_account?: #{e.message}"
      false
  end

  def account_required?
    params[:account_username].present?
  end

  def skip_temporary_suspension_response?
    true
  end

  def body
    return @body if defined?(@body)

    @body = request.body.read
    @body.force_encoding('UTF-8') if @body.present?

    request.body.rewind if request.body.respond_to?(:rewind)

    @body
  end

  def upgrade_account
    Rails.logger.info "INBOX: Starting upgrade_account"
    if signed_request_account&.ostatus?
      Rails.logger.info "INBOX: Updating account #{signed_request_account.acct}"
      signed_request_account.update(last_webfingered_at: nil)
      ResolveAccountWorker.perform_async(signed_request_account.acct)
      Rails.logger.info "INBOX: Scheduled ResolveAccountWorker for #{signed_request_account.acct}"
    end

    DeliveryFailureTracker.reset!(signed_request_actor.inbox_url)
    Rails.logger.info "INBOX: Reset delivery failure tracker for #{signed_request_actor.inbox_url}"
  end

  def process_collection_synchronization
    Rails.logger.info "INBOX: Starting process_collection_synchronization"
    raw_params = request.headers['Collection-Synchronization']
    Rails.logger.debug "INBOX: Collection-Synchronization Header: #{raw_params}"
    return if raw_params.blank? || ENV['DISABLE_FOLLOWERS_SYNCHRONIZATION'] == 'true' || signed_request_account.nil?

    # Re-using the syntax for signature parameters
    params = SignatureParser.parse(raw_params)
    Rails.logger.debug "INBOX: Collection-Synchronization Parameters: #{params}"
    ActivityPub::PrepareFollowersSynchronizationService.new.call(signed_request_account, params)
  rescue SignatureParser::ParsingError
    Rails.logger.warn 'Error parsing Collection-Synchronization header'
  end

  def process_payload
    Rails.logger.info "INBOX: Starting process_payload for actor: #{signed_request_actor.id}"
    ActivityPub::ProcessingWorker.perform_async(signed_request_actor.id, body, @account&.id, signed_request_actor.class.name)
    Rails.logger.info "INBOX: Scheduled ActivityPub::ProcessingWorker for actor: #{signed_request_actor.id}"
  end
end
