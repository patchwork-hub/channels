# frozen_string_literal: true

class CustomNotificationService < BaseService
  def call(recipient, notification)
    Rails.logger.info("**********recipient: #{recipient} , notification: #{notification}**********")
    notification_tokens = NotificationToken.where(account_id: recipient.id)

    return unless notification_tokens.any?

    body = ''
    destination_id = 0
    from_account_username = Account.find(notification.from_account_id).username

    case notification.type
    when :status, :update
      # body = ""
      # destination_id = 0
    when :reblog
      body = "#{from_account_username} boosted your status"
      destination_id = Status.find(notification.activity_id).id
    when :favourite
      body = "#{from_account_username} favourited your status"
      favourite = Favourite.find(notification.activity_id)
      destination_id = Status.find(favourite.status_id).id
    when :mention
      body = "#{from_account_username} mentioned you"
      mention = Mention.find(notification.activity_id)
      destination_id = Status.find(mention.status_id).id
      # notification.mention.status = cached_status
    when :poll
      # body = ""
      # destination_id = 0
    when :follow
      body = "#{from_account_username} followed you"
      destination_id = notification.from_account_id
    end

    data = {
      noti_type: notification.type,
      destination_id: destination_id.to_s,
    }
    Rails.logger.info("**********data: #{data} **********")
    ## ios & android
    ios_android_devices = notification_tokens.where.not(platform_type: 'huawei').pluck(:notification_token)
    Rails.logger.info("**********ios_android_devices: #{ios_android_devices} , ios_android_devices.last: #{ios_android_devices.last}**********")

    FirebaseNotificationService.send_notification(ios_android_devices.last, 'Patchwork', body, data) if ios_android_devices.any?

    # ## huawei
    # huawei_devices = notification_tokens.where(platform_type: 'huawei').pluck(:notification_token)
    # return unless huawei_devices.any? ## ios & android

    # huawei = HuaweiCloudMessaging.new
    # huawei.send_message(title, destination, destination_id, huawei_devices)
  end
end
