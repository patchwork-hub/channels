# frozen_string_literal: true

require 'googleauth'
require 'httparty'

class FirebaseNotificationService
  include HTTParty

  BASE_URL = 'https://fcm.googleapis.com/v1/projects/patchwork-279c9/messages:send'

  def self.send_notification(token, title, body, data = {})
    # Path to your service account JSON file
    service_account_file = 'config/fcm_acc_service.json'

    # Define the required scope
    scope = 'https://www.googleapis.com/auth/firebase.messaging'

    # Authenticate and get the token
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(service_account_file),
      scope: scope
    )

    # Fetch the access token
    access_token = authorizer.fetch_access_token!['access_token']

    Rails.logger.info("access_token: #{access_token}")

    return nil if access_token.blank?

    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json',
    }

    Rails.logger.info("**********payyyyyy data #{data} **********")
    payload = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: data,
      },
    }.to_json

    Rails.logger.info("**********payload: #{payload} **********")

    response = post(BASE_URL, headers: headers, body: payload)

    if response.success?
      Rails.logger.info("Notification sent successfully: #{response}")
    else
      Rails.logger.error("Error sending notification: #{response.body}")
    end
  end
end
