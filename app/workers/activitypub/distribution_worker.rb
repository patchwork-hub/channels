# frozen_string_literal: true

class ActivityPub::DistributionWorker < ActivityPub::RawDistributionWorker
  # Distribute a new status or an edit of a status to all the places
  # where the status is supposed to go or where it was interacted with
  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    @inboxes ||= begin
      all_inboxes = StatusReachFinder.new(@status).inboxes

      if @status.reblog?
        original_status = @status.reblog
        if original_status.account.domain.nil? # Skip if original status is local
          all_inboxes
        else
          # Extract domain from original status owner
          original_domain = original_status.account.domain

          # Only log if domain is mastodon.social
          if original_domain == 'mastodon.social'
            Rails.logger.info '+++++++ MASTODON.SOCIAL REBLOG DETECTED +++++++'
            Rails.logger.info "Original status ID: #{original_status.id}"
            Rails.logger.info "Original account: #{original_status.account.username}"
            Rails.logger.info "Original domain: #{original_domain}"
            Rails.logger.info "Total inboxes before filtering: #{all_inboxes.size}"
          end

          # Filter out inboxes from the same domain
          filtered_inboxes = all_inboxes.reject do |inbox_url|
            begin
              inbox_domain = URI.parse(inbox_url).host
              if original_domain == 'mastodon.social'
                Rails.logger.info "Checking inbox: #{inbox_url}"
                Rails.logger.info "Inbox domain: #{inbox_domain}"
              end
              inbox_domain == original_domain
            rescue URI::InvalidURIError
              false
            end
          end

          if original_domain == 'mastodon.social'
            Rails.logger.info "Total inboxes after filtering: #{filtered_inboxes.size}"
            Rails.logger.info '+++++++ END MASTODON.SOCIAL REBLOG +++++++'
          end
          filtered_inboxes
        end
      else
        all_inboxes
      end
    end
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(activity, ActivityPub::ActivitySerializer, signer: @account))
  end

  def activity
    ActivityPub::ActivityPresenter.from_status(@status)
  end

  def options
    { 'synchronize_followers' => @status.private_visibility? }
  end
end
