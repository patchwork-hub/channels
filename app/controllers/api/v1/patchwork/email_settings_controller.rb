# frozen_string_literal: true

class Api::V1::Patchwork::EmailSettingsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :write }
  before_action :require_user!

  def index
    notification_emails = current_user.settings.as_json.select { |key, _| key.to_s.start_with?('notification_emails.') }
    notification_emails.delete(:"notification_emails.software_updates")
    all_same = notification_emails.values.uniq.size == 1
    result_variable = all_same ? notification_emails.values.first : true

    render json: { data: result_variable }, status: :ok
  end

  def email_notification
    settings = enable_email_notification? ? email_notification_attributes(true) : email_notification_attributes(false)
    if current_user.update(settings: settings)
      render json: { message: 'Changes successfully saved.' }, status: :ok
    else
      render json: { error: 'Something went wrong!' }, status: :unprocessable_entity
    end
  end

  private

  def enable_email_notification?
    truthy_param?(params[:allowed])
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end

  def email_notification_attributes(enabled = false)
    {
      "always_send_emails" => enabled,
      "notification_emails.follow" => enabled,
      "notification_emails.reblog" => enabled,
      "notification_emails.favourite" => enabled,
      "notification_emails.mention" => enabled,
      "notification_emails.follow_request" => enabled,
      "notification_emails.report" => enabled,
      "notification_emails.pending_account" => enabled,
      "notification_emails.trends" => enabled,
      "notification_emails.appeal" => enabled,
      "notification_emails.software_updates" => enabled ? 'critical' : 'none'
    }
  end
end
