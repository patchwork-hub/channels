# frozen_string_literal: true

class ActivityPub::ProcessCollectionService < BaseService
  include JsonLdHelper

  def call(body, actor, **options)
    @account = actor
    @json    = original_json = Oj.load(body, mode: :strict)
    @options = options

    return unless @json.is_a?(Hash)

    begin
      @json = compact(@json) if @json['signature'].is_a?(Hash)
    rescue JSON::LD::JsonLdError => e
      Rails.logger.debug { "Error when compacting JSON-LD document for #{value_or_id(@json['actor'])}: #{e.message}" }
      @json = original_json.without('signature')
    end

    return if !supported_context? || (different_actor? && verify_account!.nil?) || suspended_actor? || @account.local?
    return unless @account.is_a?(Account)

    if @json['signature'].present?
      # We have verified the signature, but in the compaction step above, might
      # have introduced incompatibilities with other servers that do not
      # normalize the JSON-LD documents (for instance, previous Mastodon
      # versions), so skip redistribution if we can't get a safe document.
      patch_for_forwarding!(original_json, @json)
      @json.delete('signature') unless safe_for_forwarding?(original_json, @json)
    end
    p "*****PROCESS COLLECTION: Processing a #{@json['type']} object."


    case @json['type']
    when 'Collection', 'CollectionPage'
      p "*****PROCESS COLLECTION: Collection items: #{@json['items']}"
      process_items @json['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      p "*****PROCESS COLLECTION: Ordered collection items: #{@json['orderedItems']}"
      process_items @json['orderedItems']
    else
      p "*****PROCESS COLLECTION: Single item object: #{@json}"
      process_items [@json]
    end
  rescue Oj::ParseError
    nil
  end

  private

  def different_actor?
    @json['actor'].present? && value_or_id(@json['actor']) != @account.uri
  end

  def suspended_actor?
    @account.suspended? && !activity_allowed_while_suspended?
  end

  def activity_allowed_while_suspended?
    %w(Delete Reject Undo Update).include?(@json['type'])
  end

  def process_items(items)
    Rails.logger.info "PROCESS COLLECTION: Processing #{items.size} items."
    items.reverse_each.filter_map do |item|
      processed_item = process_item(item)
      Rails.logger.info "PROCESS COLLECTION: Item processed and status created: #{processed_item.is_a?(Status) ? processed_item.id : 'no'}"
      processed_item
    end
  end


  def supported_context?
    super(@json)
  end

  def process_item(item)
    p "*****PROCESS COLLECTION: Run ACTIVITY FACTORY for item: #{item}"
    activity = ActivityPub::Activity.factory(item, @account, **@options)
    activity&.perform
  end

  def verify_account!
    @options[:relayed_through_actor] = @account
    @account = ActivityPub::LinkedDataSignature.new(@json).verify_actor!
    @account = nil unless @account.is_a?(Account)
    @account
  rescue JSON::LD::JsonLdError, RDF::WriterError => e
    Rails.logger.debug { "Could not verify LD-Signature for #{value_or_id(@json['actor'])}: #{e.message}" }
    nil
  end
end
