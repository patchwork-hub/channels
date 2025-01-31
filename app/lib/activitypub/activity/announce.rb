# frozen_string_literal: true

class ActivityPub::Activity::Announce < ActivityPub::Activity
  include FormattingHelper

  def perform
    #dereference_object!

    return reject_payload! if delete_arrived_first?(@json['id']) || !related_to_local_activity?
    return reject_payload! if @object.nil?

    #Rails.logger.info("**** Announce   @object: #{@object.inspect} ****")

    with_redis_lock("announce:#{value_or_id(@object)}") do
      original_status = status_from_object

      return reject_payload! if original_status.nil? || !announceable?(original_status)
      return if requested_through_relay?

      @status = Status.find_by(account: @account, reblog: original_status)

      return @status unless @status.nil?

      #@status_parser = ActivityPub::Parser::StatusParser.new(@json, followers_collection: @account.followers_url, object: @object)

      #attachment_ids = process_attachments.take(Status::MEDIA_ATTACHMENTS_LIMIT).map(&:id)

      #Rails.logger.info("**** Announce   @status_parser text: #{converted_object_type? ? converted_text : (@status_parser.text || '')} ****")
      #Rails.logger.info("**** Announce   media_attachment_ids: #{attachment_ids} ****")

      #@tags                 = []
      #@mentions             = []
      #@silenced_account_ids = []

      #process_tags

      @status = Status.create!(
        account: @account,
        reblog: original_status,
        uri: @json['id'],
        created_at: @json['published'],
        override_timestamps: @options[:override_timestamps],
        visibility: visibility_from_audience
        # media_attachment_ids: attachment_ids,
        # ordered_media_attachment_ids: attachment_ids,
        # text: converted_object_type? ? converted_text : (@status_parser.text || '')
      )

      Trends.register!(@status)

      distribute
    end

    @status
  end

  private

  def converted_text
    linkify([@status_parser.title.presence, @status_parser.spoiler_text.presence, @status_parser.url || @status_parser.uri].compact.join("\n\n"))
  end

  def distribute
    # Notify the author of the original status if that status is local
    LocalNotificationWorker.perform_async(@status.reblog.account_id, @status.id, 'Status', 'reblog') if reblog_of_local_account?(@status) && !reblog_by_following_group_account?(@status)

    # Distribute into home and list feeds
    ::DistributionWorker.perform_async(@status.id) if @options[:override_timestamps] || @status.within_realtime_window?
  end

  def reblog_of_local_account?(status)
    status.reblog? && status.reblog.account.local?
  end

  def reblog_by_following_group_account?(status)
    status.reblog? && status.account.group? && status.reblog.account.following?(status.account)
  end

  def audience_to
    as_array(@json['to']).map { |x| value_or_id(x) }
  end

  def audience_cc
    as_array(@json['cc']).map { |x| value_or_id(x) }
  end

  def visibility_from_audience
    if audience_to.any? { |to| ActivityPub::TagManager.instance.public_collection?(to) }
      :public
    elsif audience_cc.any? { |cc| ActivityPub::TagManager.instance.public_collection?(cc) }
      :unlisted
    elsif audience_to.include?(@account.followers_url)
      :private
    else
      :direct
    end
  end

  def announceable?(status)
    status.account_id == @account.id || status.distributable?
  end

  def related_to_local_activity?
    followed_by_local_accounts? || requested_through_relay? || reblog_of_local_status?
  end

  def requested_through_relay?
    super || Relay.find_by(inbox_url: @account.inbox_url)&.enabled?
  end

  def reblog_of_local_status?
    status_from_uri(object_uri)&.account&.local?
  end

  # def process_attachments
  #   return [] if @object['attachment'].nil?

  #   media_attachments = []

  #   as_array(@object['attachment']).each do |attachment|
  #     media_attachment_parser = ActivityPub::Parser::MediaAttachmentParser.new(attachment)

  #     next if media_attachment_parser.remote_url.blank? || media_attachments.size >= Status::MEDIA_ATTACHMENTS_LIMIT

  #     begin
  #       media_attachment = MediaAttachment.create(
  #         account: @account,
  #         remote_url: media_attachment_parser.remote_url,
  #         thumbnail_remote_url: media_attachment_parser.thumbnail_remote_url,
  #         description: media_attachment_parser.description,
  #         focus: media_attachment_parser.focus,
  #         blurhash: media_attachment_parser.blurhash
  #       )

  #       media_attachments << media_attachment

  #       next if unsupported_media_type?(media_attachment_parser.file_content_type) || skip_download?

  #       media_attachment.download_file!
  #       media_attachment.download_thumbnail!
  #       media_attachment.save
  #     rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
  #       RedownloadMediaWorker.perform_in(rand(30..600).seconds, media_attachment.id)
  #     rescue Seahorse::Client::NetworkingError => e
  #       Rails.logger.warn "Error storing media attachment: #{e}"
  #       RedownloadMediaWorker.perform_async(media_attachment.id)
  #     end
  #   end

  #   media_attachments
  # rescue Addressable::URI::InvalidURIError => e
  #   Rails.logger.debug { "Invalid URL in attachment: #{e}" }
  #   media_attachments
  # end

  # def process_tags
  #   return if @object['tag'].nil?

  #   as_array(@object['tag']).each do |tag|
  #     if equals_or_includes?(tag['type'], 'Hashtag')
  #       process_hashtag tag
  #     elsif equals_or_includes?(tag['type'], 'Mention')
  #       process_mention tag
  #     elsif equals_or_includes?(tag['type'], 'Emoji')
  #       process_emoji tag
  #     end
  #   end
  # end

  # def process_hashtag(tag)
  #   return if tag['name'].blank?

  #   Tag.find_or_create_by_names(tag['name']) do |hashtag|
  #     @tags << hashtag unless @tags.include?(hashtag) || !hashtag.valid?
  #   end
  # rescue ActiveRecord::RecordInvalid
  #   nil
  # end

  # def process_mention(tag)
  #   return if tag['href'].blank?

  #   account = account_from_uri(tag['href'])
  #   account = ActivityPub::FetchRemoteAccountService.new.call(tag['href'], request_id: @options[:request_id]) if account.nil?

  #   return if account.nil?

  #   @mentions << Mention.new(account: account, silent: false)
  # end

  # def process_emoji(tag)
  #   return if skip_download?

  #   custom_emoji_parser = ActivityPub::Parser::CustomEmojiParser.new(tag)

  #   return if custom_emoji_parser.shortcode.blank? || custom_emoji_parser.image_remote_url.blank?

  #   emoji = CustomEmoji.find_by(shortcode: custom_emoji_parser.shortcode, domain: @account.domain)

  #   return unless emoji.nil? || custom_emoji_parser.image_remote_url != emoji.image_remote_url || (custom_emoji_parser.updated_at && custom_emoji_parser.updated_at >= emoji.updated_at)

  #   begin
  #     emoji ||= CustomEmoji.new(domain: @account.domain, shortcode: custom_emoji_parser.shortcode, uri: custom_emoji_parser.uri)
  #     emoji.image_remote_url = custom_emoji_parser.image_remote_url
  #     emoji.save
  #   rescue Seahorse::Client::NetworkingError => e
  #     Rails.logger.warn "Error storing emoji: #{e}"
  #   end
  # end

  # def skip_download?
  #   return @skip_download if defined?(@skip_download)

  #   @skip_download ||= DomainBlock.reject_media?(@account.domain)
  # end
end
