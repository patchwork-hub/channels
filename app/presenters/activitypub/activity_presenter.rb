# frozen_string_literal: true

class ActivityPub::ActivityPresenter < ActiveModelSerializers::Model
  attributes :id, :type, :actor, :published, :to, :cc, :virtual_object

  class << self
    def from_status(status, allow_inlining: true)
      new.tap do |presenter|
        presenter.id        = ActivityPub::TagManager.instance.activity_uri_for(status)
        presenter.type      = status.reblog? ? 'Announce' : 'Create'
        presenter.actor     = ActivityPub::TagManager.instance.uri_for(status.account)
        presenter.published = status.created_at

        # Get the original to/cc lists
        to_list = ActivityPub::TagManager.instance.to(status)
        cc_list = ActivityPub::TagManager.instance.cc(status)

        Rails.logger.info "++++++++ To list of #{status.reblog.account.username}: #{to_list} ++++++++"
        Rails.logger.info "++++++++ CC list of #{status.reblog.account.username}: #{cc_list} ++++++++"

        # If this is a reblog, remove the original owner from the lists
        if status.reblog?
          original_owner_uri = ActivityPub::TagManager.instance.uri_for(status.reblog.account)
          to_list = to_list.reject { |uri| uri == original_owner_uri }
          cc_list = cc_list.reject { |uri| uri == original_owner_uri }
        end

        presenter.to = to_list
        presenter.cc = cc_list

        presenter.virtual_object = begin
          if status.reblog?
            if allow_inlining && status.account == status.proper.account && status.proper.private_visibility? && status.local?
              status.proper
            else
              ActivityPub::TagManager.instance.uri_for(status.proper)
            end
          else
            status.proper
          end
        end
      end
    end
  end
end
