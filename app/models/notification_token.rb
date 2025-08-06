# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_notification_tokens
#
#  id                 :bigint(8)        not null, primary key
#  mute               :boolean          default(FALSE), not null
#  notification_token :string
#  platform_type      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint(8)        not null
#
class NotificationToken < ApplicationRecord
  self.table_name = 'patchwork_notification_tokens'
  belongs_to :account

  validates :platform_type, presence: true
  validates :notification_token, presence: true,  uniqueness: { scope: :account_id }
end
