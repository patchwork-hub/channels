# frozen_string_literal: true

# == Schema Information
#
# Table name: patchwork_wait_lists
#
#  id              :bigint(8)        not null, primary key
#  channel_type    :integer          default("channel"), not null
#  confirmed_at    :datetime
#  description     :text
#  email           :text
#  invitation_code :text             not null
#  used            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint(8)
#
class WaitList < ApplicationRecord
  self.table_name = 'patchwork_wait_lists'
  belongs_to :account, class_name: 'Account', optional: true
  
  enum :channel_type, { channel: 0, hub: 1 }

  validates :account_id, uniqueness: true, allow_nil: true
  validates :invitation_code, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :description, length: { maximum: 255 }, allow_blank: true
end
