# frozen_string_literal: true

class NotificationToken < ApplicationRecord
  self.table_name = 'patchwork_notification_tokens'
  belongs_to :account

  validates :platform_type, :notification_token, presence: true
  validates :notification_token, presence: true, uniqueness: true
end
